import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/store.dart';
import 'core_providers.dart';

part 'store_providers.g.dart';

@riverpod
class StoresList extends _$StoresList {
  @override
  Future<List<Store>> build() async {
    final logger = ref.watch(loggerServiceProvider);
    logger.i('Iniciando listado de FileSearchStores...');

    final repository = ref.watch(fileSearchRepositoryProvider);
    final result = await repository.listStores();

    return result.fold(
      (failure) {
        logger.e('Error al listar stores: ${failure.message}');
        throw Exception(failure.message);
      },
      (stores) {
        logger.i('Se obtuvieron ${stores.length} stores exitosamente.');
        return stores;
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final logger = ref.read(loggerServiceProvider);
      logger.i('Refrescando listado de FileSearchStores...');

      final repository = ref.watch(fileSearchRepositoryProvider);
      final result = await repository.listStores();
      return result.fold(
        (failure) {
          logger.e('Error al refrescar stores: ${failure.message}');
          throw Exception(failure.message);
        },
        (stores) {
          logger.i('Refresco exitoso. ${stores.length} stores encontrados.');
          return stores;
        },
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
