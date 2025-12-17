import 'package:dartz/dartz.dart';
import 'package:sakina/core/error/failures.dart';
import 'package:sakina/features/prayer_times/domain/entities/prayer_times.dart';
import 'package:sakina/features/prayer_times/domain/repositories/prayer_times_repository.dart';

class GetPrayerTimes {
  final PrayerTimesRepository repository;

  GetPrayerTimes(this.repository);

  Future<Either<Failure, PrayerTimes>> call() async {
    return await repository.getPrayerTimes();
  }
}
