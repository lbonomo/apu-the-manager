import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/document.dart';
import 'core_providers.dart';

part 'document_providers.g.dart';

@riverpod
class DocumentsList extends _$DocumentsList {
  @override
  Future<List<Document>> build(String storeId) async {
    final repository = ref.watch(fileSearchRepositoryProvider);
    final result = await repository.listDocuments(storeId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (documents) => documents,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.watch(fileSearchRepositoryProvider);
      final result = await repository.listDocuments(storeId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (documents) => documents,
      );
    });
  }

  Future<void> uploadDocument(File file, {String? displayName}) async {
    final repository = ref.read(fileSearchRepositoryProvider);
    final result = await repository.uploadDocument(storeId, file, displayName: displayName);
    result.fold(
      (failure) => throw Exception(failure.message),
      (document) => refresh(),
    );
  }

  Future<void> deleteDocument(String documentId) async {
    final repository = ref.read(fileSearchRepositoryProvider);
    final result = await repository.deleteDocument(storeId, documentId);
    result.fold(
      (failure) => throw Exception(failure.message),
      (success) => refresh(),
    );
  }
}
