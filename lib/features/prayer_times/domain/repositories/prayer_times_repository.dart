import 'package:dartz/dartz.dart';
import 'package:sakina/core/error/failures.dart';
import 'package:sakina/features/prayer_times/domain/entities/prayer_times.dart';

abstract class PrayerTimesRepository {
  Future<Either<Failure, PrayerTimes>> getPrayerTimes();
}
