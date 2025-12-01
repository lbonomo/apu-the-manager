import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../entities/store.dart';
import '../entities/document.dart';
import '../entities/document_content.dart';

import '../entities/paginated_result.dart';

abstract class FileSearchRepository {
  Future<Either<Failure, List<Store>>> listStores();
  Future<Either<Failure, Store>> createStore(String displayName);
  Future<Either<Failure, void>> deleteStore(String storeId);
  Future<Either<Failure, PaginatedResult<Document>>> listDocuments(
    String storeId, {
    int pageSize = 20,
    String? pageToken,
  });
  Future<Either<Failure, Document>> uploadDocument(
    String storeId,
    File file, {
    String? displayName,
  });
  Future<Either<Failure, void>> deleteDocument(
    String storeId,
    String documentId,
  );
  Future<Either<Failure, DocumentContent>> getDocumentContent(
    String documentName, {
    String? mimeType,
  });
}
