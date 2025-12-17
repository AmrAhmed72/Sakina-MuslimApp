import 'dart:async';
import 'dart:convert';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/azan_settings_model.dart';

@pragma('vm:entry-point')
class AzanBackgroundService {
  static const String _settingsKey = 'azan_settings';
  static const String _prayerTimesKey = 'prayer_times';

  @pragma('vm:entry-point')
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // ✅ إنشاء Notification Channel
    final notifications = FlutterLocalNotificationsPlugin();
    
    const serviceChannel = AndroidNotificationChannel(
      'prayer_service_channel',
      'خدمة مواقيت الصلاة',
      description: 'خدمة تعمل في الخلفية لإرسال تنبيهات الصلاة',
      importance: Importance.low,
      showBadge: false,
      playSound: false,
      enableVibration: false,
    );

    const azanChannel = AndroidNotificationChannel(
      'azan_channel_v3',
      'تنبيهات الأذان',
      description: 'إشعارات أوقات الصلاة مع صوت الأذان',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('azan'),
    );

    final androidPlugin = notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(serviceChannel);
      await androidPlugin.createNotificationChannel(azanChannel);
      print('✅ Notification channels created');
    }

    // ✅ تكوين الخدمة
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'prayer_service_channel',
        initialNotificationTitle: 'خدمة مواقيت الصلاة',
        initialNotificationContent: 'الخدمة تعمل في الخلفية',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    await service.startService();
  }

  @pragma('vm:entry-point')
  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    print('🚀 ============= SERVICE STARTED =============');

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    final notifications = FlutterLocalNotificationsPlugin();
    await notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    
    print('✅ Notifications initialized in service');

    // ✅ الإصلاح: نبقي الخدمة foreground بإشعار خفيف من البداية
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "خدمة مواقيت الصلاة",
        content: "الخدمة تعمل في الخلفية",
      );
      print('✅ Foreground notification set');
    }

    // ✅ Listener للإيقاف
    service.on('stopService').listen((event) {
      print('⛔ Stop service requested');
      service.stopSelf();
    });

    // ✅ Listener للاختبار من الـ UI
    service.on('sendTestNotification').listen((event) async {
      print('📢 Test notification requested from UI');
      try {
        await notifications.show(
          99999,
          '🧪 اختبار من الخدمة',
          'الخدمة شغالة والإشعارات تعمل! الوقت: ${DateTime.now().hour}:${DateTime.now().minute}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'azan_channel_v3',
              'تنبيهات الصلاة',
              channelDescription: 'تنبيهات أوقات الصلاة',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: true,
              enableVibration: true,
              playSound: true,
              sound: RawResourceAndroidNotificationSound('azan'),
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
        print('✅ Test notification sent from service');
      } catch (e) {
        print('❌ Error sending test notification: $e');
      }
    });

    // ✅ فحص فوري أول مرة
    print('🔍 Running initial check...');
    await _checkPrayerTimes(service, notifications);

    // ✅ فحص كل دقيقة
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      print('⏰ Timer tick at ${DateTime.now()}');
      try {
        await _checkPrayerTimes(service, notifications);
        
        if (service is AndroidServiceInstance) {
          final now = DateTime.now();
          service.setForegroundNotificationInfo(
            title: "خدمة مواقيت الصلاة",
            content: "آخر فحص: ${now.hour}:${now.minute.toString().padLeft(2, '0')}",
          );
        }
      } catch (e) {
        print("❌ Error in timer: $e");
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static Future<void> _checkPrayerTimes(
    ServiceInstance service,
    FlutterLocalNotificationsPlugin notifications,
  ) async {
    print('🔍 ========== CHECKING PRAYER TIMES ==========');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final settingsJson = prefs.getString(_settingsKey);
      print('📄 Settings JSON: $settingsJson');
      
      if (settingsJson == null) {
        print('❌ No settings found');
        return;
      }

      final settings = AzanSettings.fromJson(jsonDecode(settingsJson));
      print('✅ Settings loaded: generalEnabled=${settings.generalEnabled}');
      
      if (!settings.generalEnabled) {
        print('⚠️ Azan is disabled in settings');
        return;
      }

      final prayerTimesJson = prefs.getString(_prayerTimesKey);
      print('📄 Prayer Times JSON: $prayerTimesJson');
      
      if (prayerTimesJson == null) {
        print('❌ No prayer times found');
        return;
      }

      final prayerTimes = jsonDecode(prayerTimesJson) as Map<String, dynamic>;
      print('✅ Prayer times loaded: $prayerTimes');

      final now = DateTime.now();
      final current = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      print('🕐 Current time: $current');

      for (final entry in settings.prayerSettings.entries) {
        final prayerName = entry.key;
        final prayerSetting = entry.value;

        if (!prayerSetting.enabled) {
          print('⏭️ $prayerName is disabled, skipping');
          continue;
        }

        final prayerTime = prayerTimes[prayerName.toLowerCase()];
        if (prayerTime == null) {
          print('⚠️ No time found for $prayerName (looking for key: ${prayerName.toLowerCase()})');
          continue;
        }

        print('🔍 Checking $prayerName: current=$current, prayer=$prayerTime');

        if (_isTimeMatch(current, prayerTime)) {
          print('✅✅✅ TIME MATCHED FOR $prayerName! ✅✅✅');
          await _showPrayerNotification(
            prayerName,
            prayerTime,
            notifications,
            prefs,
            service,
          );
          break;
        } else {
          print('❌ No match for $prayerName');
        }
      }
      
      print('🔍 ========== CHECK COMPLETE ==========');
    } catch (e, stackTrace) {
      print("❌ CRITICAL ERROR in _checkPrayerTimes: $e");
      print("Stack trace: $stackTrace");
    }
  }

  @pragma('vm:entry-point')
  static bool _isTimeMatch(String now, String prayer) {
    try {
      print('🔍 Comparing times: now="$now", prayer="$prayer"');
      
      final nowParts = now.split(':');
      final prayerParts = prayer.split(':');
      
      if (nowParts.length != 2 || prayerParts.length != 2) {
        print('❌ Invalid time format');
        return false;
      }
      
      final nowHour = int.parse(nowParts[0]);
      final nowMin = int.parse(nowParts[1]);
      
      final prayerHour = int.parse(prayerParts[0]);
      final prayerMin = int.parse(prayerParts[1]);
      
      // تحويل الوقت لدقائق للمقارنة
      final nowTotalMinutes = nowHour * 60 + nowMin;
      final prayerTotalMinutes = prayerHour * 60 + prayerMin;
      
      // نطاق زمني: من وقت الأذان لحد دقيقتين بعده
      final diff = nowTotalMinutes - prayerTotalMinutes;
      final match = diff >= 0 && diff <= 2;
      
      print('Match result: $match (now: $nowHour:$nowMin, prayer: $prayerHour:$prayerMin, diff: $diff minutes)');
      
      return match;
    } catch (e) {
      print("❌ Time match error: $e");
      return false;
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _showPrayerNotification(
    String prayerName,
    String prayerTime,
    FlutterLocalNotificationsPlugin notifications,
    SharedPreferences prefs,
    ServiceInstance service,
  ) async {
    try {
      // منع التكرار في نفس اليوم
      final today = DateTime.now();
      final todayKey = "${prayerName}_${today.year}_${today.month}_${today.day}";
      if (prefs.getString("last_azan_$prayerName") == todayKey) {
        print("تم التنبيه بالفعل لصلاة $prayerName اليوم");
        return;
      }
      await prefs.setString("last_azan_$prayerName", todayKey);

      // إعدادات الإشعار مع صوت الأذان + full screen intent
      const androidDetails = AndroidNotificationDetails(
        'azan_channel_v3',
        'تنبيهات الأذان',
        channelDescription: 'إشعارات أوقات الصلاة مع صوت الأذان',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'حان وقت الصلاة',
        playSound: true,
        sound: RawResourceAndroidNotificationSound('azan'),
        enableVibration: true,
        enableLights: true,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );

      const details = NotificationDetails(android: androidDetails);

      await notifications.show(
        100,
        "حان الآن وقت صلاة $prayerName",
        "الوقت: $prayerTime • تقبل الله طاعتكم",
        details,
      );

      print("تم تشغيل أذان $prayerName بنجاح");

    } catch (e) {
      print("خطأ في عرض إشعار الأذان: $e");
    }
  }

  // ✅ حفظ مواقيت الصلاة
  @pragma('vm:entry-point')
  static Future<void> savePrayerTimes(Map<String, String> prayerTimes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prayerTimesKey, jsonEncode(prayerTimes));
    print("✅ Prayer times saved: $prayerTimes");
  }
}