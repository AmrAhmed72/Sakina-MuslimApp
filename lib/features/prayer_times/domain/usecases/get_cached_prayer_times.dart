import 'dart:convert';

import 'package:sakina/core/services/local_storage_service.dart';
import 'package:sakina/features/prayer_times/domain/entities/prayer_times.dart';

class GetCachedPrayerTimes {
  GetCachedPrayerTimes();

  PrayerTimes? call() {
    try {
      final raw = LocalStorageService.getCachedPrayerTimes();
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
        return PrayerTimes(
          fajr: map['fajr'] ?? '',
          dhuhr: map['dhuhr'] ?? '',
          asr: map['asr'] ?? '',
          maghrib: map['maghrib'] ?? '',
          isha: map['isha'] ?? '',
          sunrise: map['sunrise'] ?? '',
          hijriDate: map['hijriDate'] ?? '',
          gregorianDate: map['gregorianDate'] ?? '',
          nextPrayer: map['nextPrayer'] ?? '',
          nextPrayerTime: map['nextPrayerTime'] ?? '',
        );
      }
    } catch (_) {}
    return null;
  }
}
