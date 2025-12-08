import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:apu_the_manager/data/datasources/file_search_remote_data_source.dart';
import 'package:apu_the_manager/data/models/store_model.dart';
import 'package:apu_the_manager/core/services/logger_service.dart';
import '../../helpers/test_helper.mocks.dart';

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late FileSearchRemoteDataSourceImpl dataSource;
  late MockDio mockDio;
  late MockSettingsRepository mockSettingsRepository;
  late MockLoggerService mockLoggerService;

  setUp(() {
    mockDio = MockDio();
    mockSettingsRepository = MockSettingsRepository();
    mockLoggerService = MockLoggerService();
    dataSource = FileSearchRemoteDataSourceImpl(
      dio: mockDio,
      settingsRepository: mockSettingsRepository,
      logger: mockLoggerService,
    );
  });

  group('listStores', () {
    const tApiKey = 'test_api_key';
    final tStoreModelList = [
      const StoreModel(name: 'fileSearchStores/123', displayName: 'Test Store'),
    ];

    test(
      'should return list of stores when the response code is 200',
      () async {
        // arrange
        when(
          mockSettingsRepository.getGeminiApiKey(),
        ).thenAnswer((_) async => tApiKey);

        when(
          mockDio.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'fileSearchStores': [
                {'name': 'fileSearchStores/123', 'displayName': 'Test Store'},
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // act
        final result = await dataSource.listStores();

        // assert
        verify(mockSettingsRepository.getGeminiApiKey());
        verify(
          mockDio.get(
            'https://generativelanguage.googleapis.com/v1beta/fileSearchStores',
            queryParameters: {'key': tApiKey},
          ),
        );
        expect(result, equals(tStoreModelList));
      },
    );

    test('should throw an Exception when API Key is not set', () async {
      // arrange
      when(
        mockSettingsRepository.getGeminiApiKey(),
      ).thenAnswer((_) async => null);

      // act
      expect(
        dataSource.listStores(),
        throwsA(
          predicate((e) => e.toString().contains('Gemini API Key not set')),
        ),
      );
      verify(mockSettingsRepository.getGeminiApiKey());
      verifyZeroInteractions(mockDio);
    });
  });
}
