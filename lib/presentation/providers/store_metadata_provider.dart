import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/store_metadata_repository.dart';
import '../../domain/entities/store_metadata_config.dart';

final storeMetadataRepositoryProvider = Provider<StoreMetadataRepository>((ref) {
  return StoreMetadataRepository();
});

final storeMetadataConfigProvider = 
    AsyncNotifierProvider.family<StoreMetadataConfigNotifier, StoreMetadataConfig, String>(
  StoreMetadataConfigNotifier.new,
);

class StoreMetadataConfigNotifier extends FamilyAsyncNotifier<StoreMetadataConfig, String> {
  
  @override
  Future<StoreMetadataConfig> build(String arg) async {
    final repository = ref.read(storeMetadataRepositoryProvider);
    return repository.getConfig(arg);
  }

  Future<void> updateConfig(StoreMetadataConfig newConfig) async {
    final repository = ref.read(storeMetadataRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.saveConfig(newConfig);
      return newConfig;
    });
  }
  
  Future<void> addField(String key) async {
    final currentConfig = state.value;
    if (currentConfig == null) return;
    
    if (currentConfig.fields.any((f) => f.key == key)) return; // No duplicados

    final newFields = List<MetadataFieldConfig>.from(currentConfig.fields)
      ..add(MetadataFieldConfig(key: key));
    
    await updateConfig(currentConfig.copyWith(fields: newFields));
  }

  Future<void> removeField(String key) async {
    final currentConfig = state.value;
    if (currentConfig == null) return;

    final newFields = currentConfig.fields.where((f) => f.key != key).toList();
    await updateConfig(currentConfig.copyWith(fields: newFields));
  }

  Future<void> addValueToField(String key, String value) async {
    final currentConfig = state.value;
    if (currentConfig == null) return;

    final newFields = currentConfig.fields.map((f) {
      if (f.key == key) {
        if (f.possibleValues.contains(value)) return f;
        return MetadataFieldConfig(
          key: f.key,
          possibleValues: [...f.possibleValues, value],
        );
      }
      return f;
    }).toList();

    await updateConfig(currentConfig.copyWith(fields: newFields));
  }

  Future<void> removeValueFromField(String key, String value) async {
    final currentConfig = state.value;
    if (currentConfig == null) return;

    final newFields = currentConfig.fields.map((f) {
      if (f.key == key) {
        return MetadataFieldConfig(
          key: f.key,
          possibleValues: f.possibleValues.where((v) => v != value).toList(),
        );
      }
      return f;
    }).toList();

    await updateConfig(currentConfig.copyWith(fields: newFields));
  }
}
