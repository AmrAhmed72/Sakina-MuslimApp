import 'package:equatable/equatable.dart';

abstract class PrayerTimesEvent extends Equatable {
  const PrayerTimesEvent();

  @override
  List<Object> get props => [];
}

class GetPrayerTimesEvent extends PrayerTimesEvent {}
