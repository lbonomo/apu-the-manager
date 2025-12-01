import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:apu_the_manager/data/datasources/file_search_remote_data_source.dart';
import 'package:apu_the_manager/domain/repositories/settings_repository.dart';

@GenerateMocks([FileSearchRemoteDataSource, Dio, SettingsRepository])
void main() {}
