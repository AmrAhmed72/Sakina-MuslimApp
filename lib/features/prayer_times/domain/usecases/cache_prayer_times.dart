import 'dart:convert';

import 'package:sakina/core/services/local_storage_service.dart';
import 'package:sakina/features/prayer_times/domain/entities/prayer_times.dart';

class CachePrayerTimes {
  CachePrayerTimes();

  Future<void> call(PrayerTimes prayerTimes) async {
    try {
      final cacheMap = {
        'fajr': prayerTimes.fajr,
        'dhuhr': prayerTimes.dhuhr,
        'asr': prayerTimes.asr,
        'maghrib': prayerTimes.maghrib,
        'isha': prayerTimes.isha,
        'sunrise': prayerTimes.sunrise,
        'hijriDate': prayerTimes.hijriDate,
        'gregorianDate': prayerTimes.gregorianDate,
        'nextPrayer': prayerTimes.nextPrayer,
        'nextPrayerTime': prayerTimes.nextPrayerTime,
      };
      await LocalStorageService.saveCachedPrayerTimes(jsonEncode(cacheMap));
    } catch (_) {
      // swallow errors; caching is best-effort
    }
  }
}
