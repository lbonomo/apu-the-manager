import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/file_search_remote_data_source.dart';
import '../../data/repositories/file_search_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/file_search_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../core/services/logger_service.dart';

part 'core_providers.g.dart';

@riverpod
Dio dio(Ref ref) {
  return Dio();
}

@riverpod
FileSearchRemoteDataSource fileSearchRemoteDataSource(Ref ref) {
  return FileSearchRemoteDataSourceImpl(
    dio: ref.watch(dioProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
    logger: ref.watch(loggerServiceProvider),
  );
}

@riverpod
FileSearchRepository fileSearchRepository(Ref ref) {
  return FileSearchRepositoryImpl(
    remoteDataSource: ref.watch(fileSearchRemoteDataSourceProvider),
  );
}

@Riverpod(keepAlive: true)
LoggerService loggerService(Ref ref) {
  return LoggerServiceImpl();
}

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepositoryImpl();
}
