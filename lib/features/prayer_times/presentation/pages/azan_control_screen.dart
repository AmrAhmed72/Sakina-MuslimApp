import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sakina/core/di/injection_container.dart';
import 'package:sakina/core/services/local_storage_service.dart';
import 'package:sakina/features/prayer_times/data/services/azan_background_service.dart';
import '../bloc/azan_bloc.dart';
import '../bloc/azan_event.dart';
import '../bloc/azan_state.dart';

class AzanControlScreen extends StatefulWidget {
  const AzanControlScreen({Key? key}) : super(key: key);

  @override
  State<AzanControlScreen> createState() => _AzanControlScreenState();
}

class _AzanControlScreenState extends State<AzanControlScreen> {
  final Map<String, IconData> prayerIcons = {
    'Fajr': Icons.nights_stay,
    'Dhuhr': Icons.wb_sunny,
    'Asr': Icons.wb_cloudy,
    'Maghrib': Icons.brightness_3,
    'Isha': Icons.bedtime,
  };

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _checkBackgroundServicePermission();
  }

  Future<void> _checkBackgroundServicePermission() async {
    await Future.delayed(const Duration(seconds: 2));

    final settings = await LocalStorageService.getAzanSettings();
    final times = LocalStorageService.getAzanPrayerTimes();

    print('Background Check:');
    print('Settings: $settings');
    print('Prayer Times: $times');

    if (settings == null) print('No settings saved yet');
    if (times == null) print('No prayer times saved yet');
  }

  Future<void> _requestPermissions() async {
    final plugin = FlutterLocalNotificationsPlugin();
    final granted = await plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (granted != true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تفعيل الإشعارات للصلاة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF202020),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFE2BE7F)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Text(
            'إعدادات الإشعار',
            style: GoogleFonts.elMessiri(
              color: const Color(0xFFE2BE7F),
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: const [SizedBox(width: 56)],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/sura_details_bg.png"),
              fit: BoxFit.cover,
              opacity: 0.07,
            ),
          ),
          child: SafeArea(
            child: BlocProvider(
              create: (_) => sl<AzanBloc>()..add(LoadAzanSettings()),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // === إعدادات الأذان ===
                    BlocBuilder<AzanBloc, AzanState>(
                      builder: (context, state) {
                        if (state is AzanSettingsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(color: Color(0xFFE2BE7F)),
                          );
                        }

                        if (state is AzanSettingsLoaded) {
                          final settings = state.settings;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // العنوان
                              Text(
                                'الإعدادات العامة',
                                style: GoogleFonts.elMessiri(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFE2BE7F),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // الإعدادات العامة
                              GlassCard(
                                child: Column(
                                  children: [
                                    AzanSwitch(
  title: 'تفعيل الإشعار',
  value: settings.generalEnabled,
  onChanged: (v) async {
    // أول حاجة: احفظ القيمة
    context.read<AzanBloc>().add(UpdateGeneralSetting(enabled: v));

    // المهم جدًا: لو المستخدم فعّل → نفذ الخدمة فورًا
    if (v == true) {
      await AzanBackgroundService.initializeService();
      print("تم تفعيل الإشعار → الخدمة شغالة دلوقتي");
    } 
    // لو المستخدم عطل → أوقف الخدمة
    else {
      await AzanBackgroundService.stopService();
      print("تم تعطيل الإشعار → الخدمة توقفت");
    }
  },
),
                                    AzanSwitch(
                                      title: 'التشغيل في الخلفية',
                                      value: settings.backgroundEnabled,
                                      onChanged: (v) => context.read<AzanBloc>().add(
                                            UpdateGeneralSetting(background: v),
                                          ),
                                    ),
                                    const SizedBox(height: 16),

                                    // أزرار الاختبار والتحكم
                                    //_buildTestButtons(context),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // إعدادات كل صلاة
                              ...settings.prayerSettings.entries.map((entry) {
                                final prayer = entry.key;
                                final setting = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: GlassPrayerCard(
                                    prayerName: prayer,
                                    icon: prayerIcons[prayer] ?? Icons.mosque,
                                    setting: setting,
                                    onEnabledChanged: (v) => context.read<AzanBloc>().add(
                                          UpdatePrayerSetting(prayerName: prayer, enabled: v),
                                        ),
                                  ),
                                );
                              }),
                            ],
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // === مجموعة أزرار الاختبار والتحكم في الخدمة ===
  Widget _buildTestButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _testSimpleNotification(context),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE2BE7F)),
          child: const Text('اختبر الإشعار'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _setTestPrayerTime(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('اختبار بوقت حقيقي (دقيقتين)'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _analyzePrayerTimes(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
          child: const Text('تحليل المواقيت'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _showSavedData(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('فحص البيانات المحفوظة'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _restartService(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('إعادة تشغيل الخدمة'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _checkServiceStatus(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          child: const Text('فحص حالة الخدمة'),
        ),
      ],
    );
  }

  void _testSimpleNotification(BuildContext context) async {
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      await plugin.initialize(const InitializationSettings(android: androidSettings));

      const androidDetails = AndroidNotificationDetails(
        'azan_channel',
        'Prayer Notifications',
        importance: Importance.high,
        priority: Priority.high,
      );
      await plugin.show(999, 'اختبار الإشعار', 'وقت الصلاة الآن', const NotificationDetails(android: androidDetails));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تشغيل الإشعار للاختبار')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    }
  }

  void _setTestPrayerTime(BuildContext context) async {
    final now = DateTime.now();
    final testTime = now.add(const Duration(minutes: 1));
    final timeStr = "${testTime.hour.toString().padLeft(2, '0')}:${testTime.minute.toString().padLeft(2, '0')}";

    await LocalStorageService.saveAzanPrayerTimes({
      'fajr': timeStr,
      'dhuhr': '12:00',
      'asr': '15:00',
      'maghrib': '18:00',
      'isha': '19:30',
    });

    await AzanBackgroundService.stopService();
    await Future.delayed(const Duration(seconds: 1));
    await AzanBackgroundService.initializeService();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم ضبط وقت اختبار الفجر على $timeStr (بعد دقيقة)'), duration: const Duration(seconds: 5)),
      );
    }
  }

  void _analyzePrayerTimes() async {
    final times = LocalStorageService.getAzanPrayerTimes();
    if (times != null) {
      for (var e in times.entries) {
        final hasNewline = e.value.contains('\n');
        final hasAMPM = e.value.contains('AM') || e.value.contains('PM');
        print('${e.key}: "${e.value}" | Newline: $hasNewline | AM/PM: $hasAMPM');
      }
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('تحليل المواقيت'),
          content: Text(times?.toString() ?? 'لا توجد مواقيت'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً'))],
        ),
      );
    }
  }

  void _showSavedData() async {
    final times = LocalStorageService.getAzanPrayerTimes();
    final settings = await LocalStorageService.getAzanSettings();

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('بيانات محفوظة'),
          content: Text('المواقيت: $times\n\nالإعدادات: $settings', style: const TextStyle(fontSize: 12)),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً'))],
        ),
      );
    }
  }

  void _restartService(BuildContext context) async {
    try {
      await AzanBackgroundService.stopService();
      await Future.delayed(const Duration(seconds: 2));
      await AzanBackgroundService.initializeService();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إعادة تشغيل الخدمة'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    }
  }

  void _checkServiceStatus(BuildContext context) async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('حالة الخدمة'),
          content: Text(
            isRunning ? 'الخدمة شغالة' : 'الخدمة متوقفة',
            style: TextStyle(fontSize: 18, color: isRunning ? Colors.green : Colors.red),
          ),
          actions: [
            if (!isRunning)
              TextButton(
                onPressed: () async {
                  await AzanBackgroundService.initializeService();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تشغيل الخدمة')));
                },
                child: const Text('تشغيل الآن'),
              ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً')),
          ],
        ),
      );
    }
  }
}

// ====================== WIDGETS ======================

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: const Color(0xFFE2BE7F).withOpacity(0.4), width: 1.8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }
}

class AzanSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AzanSwitch({Key? key, required this.title, required this.value, required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: GoogleFonts.elMessiri(color: Colors.white, fontSize: 17)),
      value: value,
      onChanged: (v) {
        onChanged(v);
        HapticFeedback.lightImpact();
      },
      activeColor: const Color(0xFFE2BE7F),
      inactiveThumbColor: Colors.white38,
      inactiveTrackColor: Colors.white10,
    );
  }
}

class GlassPrayerCard extends StatelessWidget {
  final String prayerName;
  final IconData icon;
  final dynamic setting;
  final ValueChanged<bool> onEnabledChanged;

  const GlassPrayerCard({
    Key? key,
    required this.prayerName,
    required this.icon,
    required this.setting,
    required this.onEnabledChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFE2BE7F), size: 28),
              const SizedBox(width: 12),
              Text(
                prayerName,
                style: GoogleFonts.elMessiri(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE2BE7F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AzanSwitch(
            title: 'تفعيل الإشعار',
            value: setting.enabled,
            onChanged: onEnabledChanged,
          ),
        ],
      ),
    );
  }
}