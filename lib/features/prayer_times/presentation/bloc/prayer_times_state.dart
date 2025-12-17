import 'package:equatable/equatable.dart';
import 'package:sakina/features/prayer_times/domain/entities/prayer_times.dart';

abstract class PrayerTimesState extends Equatable {
  const PrayerTimesState();

  @override
  List<Object> get props => [];
}

class PrayerTimesInitial extends PrayerTimesState {}

class PrayerTimesLoading extends PrayerTimesState {}

class PrayerTimesLoaded extends PrayerTimesState {
  final PrayerTimes prayerTimes;

  const PrayerTimesLoaded(this.prayerTimes);

  @override
  List<Object> get props => [prayerTimes];
}

class PrayerTimesLoadedFromCache extends PrayerTimesState {
  final PrayerTimes prayerTimes;

  const PrayerTimesLoadedFromCache(this.prayerTimes);

  @override
  List<Object> get props => [prayerTimes];
}

class PrayerTimesError extends PrayerTimesState {
  final String message;

  const PrayerTimesError(this.message);

  @override
  List<Object> get props => [message];
}
