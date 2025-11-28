import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/file_search_remote_data_source.dart';
import '../../data/repositories/file_search_repository_impl.dart';
import '../../domain/repositories/file_search_repository.dart';

part 'core_providers.g.dart';

@riverpod
Dio dio(DioRef ref) {
  return Dio();
}

@riverpod
FileSearchRemoteDataSource fileSearchRemoteDataSource(FileSearchRemoteDataSourceRef ref) {
  return FileSearchRemoteDataSourceImpl(dio: ref.watch(dioProvider));
}

@riverpod
FileSearchRepository fileSearchRepository(FileSearchRepositoryRef ref) {
  return FileSearchRepositoryImpl(remoteDataSource: ref.watch(fileSearchRemoteDataSourceProvider));
}
