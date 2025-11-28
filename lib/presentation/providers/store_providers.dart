import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/store.dart';
import 'core_providers.dart';

part 'store_providers.g.dart';

@riverpod
class StoresList extends _$StoresList {
  @override
  Future<List<Store>> build() async {
    final repository = ref.watch(fileSearchRepositoryProvider);
    final result = await repository.listStores();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (stores) => stores,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.watch(fileSearchRepositoryProvider);
      final result = await repository.listStores();
      return result.fold(
        (failure) => throw Exception(failure.message),
        (stores) => stores,
      );
    });
  }

  Future<void> createStore(String displayName) async {
    final repository = ref.read(fileSearchRepositoryProvider);
    final result = await repository.createStore(displayName);
    result.fold(
      (failure) => throw Exception(failure.message),
      (store) => refresh(),
    );
  }

  Future<void> deleteStore(String storeId) async {
    final repository = ref.read(fileSearchRepositoryProvider);
    final result = await repository.deleteStore(storeId);
    result.fold(
      (failure) => throw Exception(failure.message),
      (success) => refresh(),
    );
  }
}
