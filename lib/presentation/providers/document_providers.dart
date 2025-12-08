import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/document.dart';
import '../../domain/entities/document_content.dart';
import '../../domain/entities/paginated_result.dart';
import 'core_providers.dart';

part 'document_providers.g.dart';

@riverpod
class DocumentsList extends _$DocumentsList {
  @override
  Future<PaginatedResult<Document>> build(String storeId) async {
    final logger = ref.watch(loggerServiceProvider);
    logger.i('Iniciando listado de documentos para el store: $storeId');

    final repository = ref.watch(fileSearchRepositoryProvider);
    final result = await repository.listDocuments(storeId);

    return result.fold(
      (failure) {
        logger.e('Error al listar documentos: ${failure.message}');
        throw Exception(failure.message);
      },
      (paginatedResult) {
        logger.i(
          'Se obtuvieron ${paginatedResult.items.length} documentos exitosamente.',
        );
        return paginatedResult;
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final logger = ref.read(loggerServiceProvider);
      logger.i('Refrescando listado de documentos...');

      final repository = ref.watch(fileSearchRepositoryProvider);
      final result = await repository.listDocuments(storeId);
      return result.fold(
        (failure) {
          logger.e('Error al refrescar documentos: ${failure.message}');
          throw Exception(failure.message);
        },
        (paginatedResult) {
          logger.i(
            'Refresco exitoso. ${paginatedResult.items.length} documentos encontrados.',
          );
          return paginatedResult;
        },
      );
    });
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || currentState.nextPageToken == null) return;

    final logger = ref.read(loggerServiceProvider);
    logger.i('Cargando más documentos...');

    final repository = ref.read(fileSearchRepositoryProvider);
    final result = await repository.listDocuments(
      storeId,
      pageToken: currentState.nextPageToken,
    );

    result.fold(
      (failure) {
        logger.e('Error al cargar más documentos: ${failure.message}');
      },
      (newBatch) {
        logger.i(
          'Se cargaron ${newBatch.items.length} documentos adicionales.',
        );
        state = AsyncValue.data(
          PaginatedResult(
            items: [...currentState.items, ...newBatch.items],
            nextPageToken: newBatch.nextPageToken,
          ),
        );
      },
    );
  }

  Future<void> uploadDocument(File file, {String? displayName}) async {
    final repository = ref.read(fileSearchRepositoryProvider);
    final result = await repository.uploadDocument(
      storeId,
      file,
      displayName: displayName,
    );
    result.fold(
      (failure) => throw Exception(failure.message),
      (document) => refresh(),
    );
  }

  Future<void> deleteDocument(String documentId) async {
    final logger = ref.read(loggerServiceProvider);
    logger.i('Iniciando eliminación de documento: $documentId');

    final repository = ref.read(fileSearchRepositoryProvider);
    final result = await repository.deleteDocument(storeId, documentId);
    result.fold(
      (failure) {
        logger.e('Error al eliminar documento: ${failure.message}');
        throw Exception(failure.message);
      },
      (success) {
        logger.i('Documento eliminado exitosamente: $documentId');
        refresh();
      },
    );
  }

  Future<void> deleteDocuments(List<String> documentIds) async {
    if (documentIds.isEmpty) return;

    final logger = ref.read(loggerServiceProvider);
    logger.i(
      'Iniciando eliminación masiva de ${documentIds.length} documentos.',
    );

    final repository = ref.read(fileSearchRepositoryProvider);
    final errors = <String>[];

    for (final documentId in documentIds) {
      final result = await repository.deleteDocument(storeId, documentId);
      result.fold(
        (failure) {
          logger.e(
            'Error al eliminar documento $documentId: ${failure.message}',
          );
          errors.add('${failure.message} ($documentId)');
        },
        (_) {
          logger.i('Documento eliminado exitosamente: $documentId');
        },
      );
    }

    await refresh();

    if (errors.isNotEmpty) {
      throw Exception(errors.join('\n'));
    }
  }
}

@riverpod
Future<DocumentContent> documentContent(
  Ref ref,
  Document document,
) async {
  final logger = ref.watch(loggerServiceProvider);
  logger.i('Descargando contenido para el documento: ${document.name}');

  final repository = ref.watch(fileSearchRepositoryProvider);
  final result = await repository.getDocumentContent(
    document.name,
    mimeType: document.mimeType,
  );

  return result.fold(
    (failure) {
      logger.e('Error al obtener contenido: ${failure.message}');
      throw Exception(failure.message);
    },
    (content) {
      logger.i(
        'Contenido obtenido (${content.byteLength} bytes) para ${document.name}.',
      );
      return content;
    },
  );
}
