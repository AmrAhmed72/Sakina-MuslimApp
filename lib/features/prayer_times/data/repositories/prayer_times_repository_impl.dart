import 'package:dartz/dartz.dart';
import 'package:sakina/core/error/exceptions.dart';
import 'package:sakina/core/error/failures.dart';
import 'package:sakina/features/prayer_times/data/datasources/prayer_times_remote_data_source.dart';
import 'package:sakina/features/prayer_times/domain/entities/prayer_times.dart';
import 'package:sakina/features/prayer_times/domain/repositories/prayer_times_repository.dart';

class PrayerTimesRepositoryImpl implements PrayerTimesRepository {
  final PrayerTimesRemoteDataSource remoteDataSource;

  PrayerTimesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PrayerTimes>> getPrayerTimes() async {
    try {
      final prayerTimes = await remoteDataSource.getPrayerTimes();
      return Right(prayerTimes);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
