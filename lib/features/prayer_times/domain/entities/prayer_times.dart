import 'package:equatable/equatable.dart';

class PrayerTimes extends Equatable {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String sunrise;
  final String hijriDate;
  final String gregorianDate;
  final String nextPrayer;
  final String nextPrayerTime;

  const PrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.sunrise,
    required this.hijriDate,
    required this.gregorianDate,
    required this.nextPrayer,
    required this.nextPrayerTime,
  });

  @override
  List<Object?> get props => [
        fajr,
        dhuhr,
        asr,
        maghrib,
        isha,
        sunrise,
        hijriDate,
        gregorianDate,
        nextPrayer,
        nextPrayerTime,
      ];
}
