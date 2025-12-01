import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/document.dart';
import '../../domain/entities/document_content.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/file_search_repository.dart';
import '../datasources/file_search_remote_data_source.dart';

import '../../domain/entities/paginated_result.dart';

class FileSearchRepositoryImpl implements FileSearchRepository {
  final FileSearchRemoteDataSource remoteDataSource;

  FileSearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Store>>> listStores() async {
    try {
      final stores = await remoteDataSource.listStores();
      return Right(stores);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Store>> createStore(String displayName) async {
    try {
      final store = await remoteDataSource.createStore(displayName);
      return Right(store);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStore(String storeId) async {
    try {
      await remoteDataSource.deleteStore(storeId);
      return Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<Document>>> listDocuments(
    String storeId, {
    int pageSize = 20,
    String? pageToken,
  }) async {
    try {
      final result = await remoteDataSource.listDocuments(
        storeId,
        pageSize: pageSize,
        pageToken: pageToken,
      );
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Document>> uploadDocument(
    String storeId,
    File file, {
    String? displayName,
  }) async {
    try {
      final document = await remoteDataSource.uploadDocument(
        storeId,
        file,
        displayName: displayName,
      );
      return Right(document);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(
    String storeId,
    String documentId,
  ) async {
    try {
      await remoteDataSource.deleteDocument(storeId, documentId);
      return Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DocumentContent>> getDocumentContent(
    String documentName, {
    String? mimeType,
  }) async {
    try {
      final content = await remoteDataSource.getDocumentContent(
        documentName,
        mimeType: mimeType,
      );
      return Right(content);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
