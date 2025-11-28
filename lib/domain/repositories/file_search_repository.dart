import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../entities/store.dart';
import '../entities/document.dart';

abstract class FileSearchRepository {
  Future<Either<Failure, List<Store>>> listStores();
  Future<Either<Failure, Store>> createStore(String displayName);
  Future<Either<Failure, void>> deleteStore(String storeId);
  Future<Either<Failure, List<Document>>> listDocuments(String storeId);
  Future<Either<Failure, Document>> uploadDocument(String storeId, File file, {String? displayName});
  Future<Either<Failure, void>> deleteDocument(String storeId, String documentId);
}
