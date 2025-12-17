import 'package:sakina/features/prayer_times/domain/entities/prayer_times.dart';

class PrayerTimesModel extends PrayerTimes {
  const PrayerTimesModel({
    required super.fajr,
    required super.dhuhr,
    required super.asr,
    required super.maghrib,
    required super.isha,
    required super.sunrise,
    required super.hijriDate,
    required super.gregorianDate,
    required super.nextPrayer,
    required super.nextPrayerTime,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    final hijri = json['data']['date']['hijri'];
    final gregorian = json['data']['date']['gregorian'];

    // Calculate next prayer
    final now = DateTime.now();
    final prayers = {
      'Fajr': timings['Fajr'],
      'Dhuhr': timings['Dhuhr'],
      'Asr': timings['Asr'],
      'Maghrib': timings['Maghrib'],
      'Isha': timings['Isha'],
    };

    String nextPrayer = 'Fajr';
    String nextPrayerTime = timings['Fajr'];

    for (var entry in prayers.entries) {
      final prayerTime = _parseTime(entry.value);
      if (prayerTime.isAfter(now)) {
        nextPrayer = entry.key;
        nextPrayerTime = entry.value;
        break;
      }
    }

    return PrayerTimesModel(
      fajr: _formatTime(timings['Fajr']),
      dhuhr: _formatTime(timings['Dhuhr']),
      asr: _formatTime(timings['Asr']),
      maghrib: _formatTime(timings['Maghrib']),
      isha: _formatTime(timings['Isha']),
      sunrise: _formatTime(timings['Sunrise']),
      hijriDate: '${hijri['day']} ${hijri['month']['ar']}, ${hijri['year']}',
      gregorianDate:
          '${gregorian['day']} ${gregorian['month']['en']}, ${gregorian['year']}',
      nextPrayer: nextPrayer,
      nextPrayerTime: _formatTime(nextPrayerTime),
    );
  }

  static String _formatTime(String time) {
    // Remove timezone info if exists
    final cleanTime = time.split(' ')[0];
    final parts = cleanTime.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];

    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    return '$hour:$minute\n$period';
  }

  static DateTime _parseTime(String time) {
    final cleanTime = time.split(' ')[0];
    final parts = cleanTime.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
