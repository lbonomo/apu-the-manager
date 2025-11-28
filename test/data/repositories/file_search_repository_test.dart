import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:apu_the_manager/data/repositories/file_search_repository_impl.dart';
import 'package:apu_the_manager/data/models/store_model.dart';
import 'package:apu_the_manager/core/errors/failures.dart';
import '../../helpers/test_helper.mocks.dart';

void main() {
  late FileSearchRepositoryImpl repository;
  late MockFileSearchRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockFileSearchRemoteDataSource();
    repository = FileSearchRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('listStores', () {
    final tStoreModelList = [
      const StoreModel(name: 'fileSearchStores/123', displayName: 'Test Store')
    ];
    final tStoreList = tStoreModelList;

    test(
      'should return list of stores when the call to remote data source is successful',
      () async {
        // arrange
        when(mockRemoteDataSource.listStores())
            .thenAnswer((_) async => tStoreModelList);
        // act
        final result = await repository.listStores();
        // assert
        verify(mockRemoteDataSource.listStores());
        expect(result, equals(Right(tStoreList)));
      },
    );

    test(
      'should return server failure when the call to remote data source is unsuccessful',
      () async {
        // arrange
        when(mockRemoteDataSource.listStores())
            .thenThrow(const ServerFailure('Server Error'));
        // act
        final result = await repository.listStores();
        // assert
        verify(mockRemoteDataSource.listStores());
        expect(result, equals(const Left(ServerFailure('Server Error'))));
      },
    );
  });
}
