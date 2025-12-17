import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakina/features/prayer_times/domain/usecases/get_prayer_times.dart';
import 'package:sakina/features/prayer_times/domain/usecases/cache_prayer_times.dart';
import 'package:sakina/features/prayer_times/domain/usecases/get_cached_prayer_times.dart';
import 'package:sakina/features/prayer_times/domain/usecases/get_azan_settings.dart';
import 'package:sakina/features/prayer_times/domain/entities/prayer_times.dart';
import 'package:sakina/features/prayer_times/presentation/bloc/prayer_times_event.dart';
import 'package:sakina/features/prayer_times/presentation/bloc/prayer_times_state.dart';
import 'package:sakina/features/prayer_times/data/services/azan_background_service.dart';
import 'package:sakina/core/services/local_storage_service.dart';

class PrayerTimesBloc extends Bloc<PrayerTimesEvent, PrayerTimesState> {
  final GetPrayerTimes getPrayerTimes;
  final CachePrayerTimes cachePrayerTimes;
  final GetCachedPrayerTimes getCachedPrayerTimes;
  final GetAzanSettings getAzanSettings;

  PrayerTimesBloc({
    required this.getPrayerTimes,
    required this.cachePrayerTimes,
    required this.getCachedPrayerTimes,
    required this.getAzanSettings,
  }) : super(PrayerTimesInitial()) {
    on<GetPrayerTimesEvent>(_onGetPrayerTimes);
  }

  Future<void> _onGetPrayerTimes(
    GetPrayerTimesEvent event,
    Emitter<PrayerTimesState> emit,
  ) async {
    emit(PrayerTimesLoading());

    final result = await getPrayerTimes();

    PrayerTimes? loaded;
    String? failureMessage;

    result.fold(
      (failure) => failureMessage = failure.message,
      (prayerTimes) => loaded = prayerTimes,
    );

    if (loaded != null) {
      emit(PrayerTimesLoaded(loaded!));
      
      try {
        // ✅ 1. حفظ في Cache العادي للـ UI
        await cachePrayerTimes(loaded!);
        
        // ✅ 2. تنضيف وتحويل المواقيت للفورمات الصحيح
        final prayerTimesMap = {
          'fajr': _cleanTime(loaded!.fajr),
          'dhuhr': _cleanTime(loaded!.dhuhr),
          'asr': _cleanTime(loaded!.asr),
          'maghrib': _cleanTime(loaded!.maghrib),
          'isha': _cleanTime(loaded!.isha),
        };
        
        print('🧹 Original times: {fajr: ${loaded!.fajr}, dhuhr: ${loaded!.dhuhr}}');
        print('✅ Cleaned times: $prayerTimesMap');
        
        // ✅ 3. حفظ للـ Background Service
        await LocalStorageService.saveAzanPrayerTimes(prayerTimesMap);
        
        print('✅ Prayer times saved for Azan: $prayerTimesMap');
        
        // ✅ 4. تشغيل الخدمة لو مفعّلة
        final azanSettings = await getAzanSettings();
        if (azanSettings.generalEnabled && azanSettings.backgroundEnabled) {
          await AzanBackgroundService.initializeService();
        }
      } catch (e) {
        print('❌ Error saving prayer times for Azan: $e');
      }
      return;
    }

    // في حالة الفشل، حاول تجيب من الـ Cache
    try {
      final cached = getCachedPrayerTimes();
      if (cached != null) {
        emit(PrayerTimesLoadedFromCache(cached));
        return;
      }
    } catch (_) {}

    emit(PrayerTimesError(failureMessage ?? 'Unknown error'));
  }

  // ✅ دالة لتنضيف الوقت من AM/PM و newlines
  String _cleanTime(String time) {
    print('🔧 Cleaning time: "$time"');
    
    // إزالة newlines و spaces زيادة
    String cleaned = time
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .trim();
    
    // فحص إذا كان فيه AM/PM
    bool isPM = cleaned.toUpperCase().contains('PM');
    bool isAM = cleaned.toUpperCase().contains('AM');
    
    // إزالة AM/PM
    cleaned = cleaned
        .replaceAll('AM', '')
        .replaceAll('PM', '')
        .replaceAll('am', '')
        .replaceAll('pm', '')
        .trim();
    
    // التأكد من الفورمات HH:MM
    if (cleaned.contains(':')) {
      final parts = cleaned.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0].trim());
        final minute = int.tryParse(parts[1].trim());
        
        if (hour != null && minute != null) {
          int finalHour = hour;
          
          // تحويل لـ 24-hour format
          if (isPM && hour != 12) {
            finalHour = hour + 12;
          } else if (isAM && hour == 12) {
            finalHour = 0;
          }
          
          final result = '${finalHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
          print('✅ Cleaned result: "$result"');
          return result;
        }
      }
    }
    
    // إذا فشل التنضيف، أرجع القيمة الأصلية
    print('⚠️ Could not clean time, returning: "$cleaned"');
    return cleaned;
  }
}