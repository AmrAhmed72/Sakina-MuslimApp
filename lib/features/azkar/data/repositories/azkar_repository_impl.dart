import 'package:dartz/dartz.dart';
import 'package:sakina/core/error/exceptions.dart';
import 'package:sakina/core/error/failures.dart';
import 'package:sakina/features/azkar/data/datasources/azkar_local_data_source.dart';
import 'package:sakina/features/azkar/domain/entities/zekr.dart';
import 'package:sakina/features/azkar/domain/repositories/azkar_repository.dart';

class AzkarRepositoryImpl implements AzkarRepository {
  final AzkarLocalDataSource localDataSource;

  AzkarRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Zekr>>> getAllAzkar() async {
    try {
      final azkar = await localDataSource.getAllAzkar();
      return Right(azkar);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Zekr>> getRandomZekr() async {
    try {
      final zekr = await localDataSource.getRandomZekr();
      return Right(zekr);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Zekr>>> getAzkarByCategory(
      String category) async {
    try {
      final azkar = await localDataSource.getAzkarByCategory(category);
      return Right(azkar);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }
}
