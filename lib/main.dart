import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:sakina/core/di/injection_container.dart' as di;
import 'package:sakina/core/services/local_storage_service.dart';
import 'package:sakina/features/prayer_times/data/services/azan_background_service.dart';
import 'package:sakina/hadeth_details_screen.dart';
import 'package:sakina/home_screen.dart';
import 'package:sakina/introduction_screen.dart';
import 'package:sakina/sura_details_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Initialize timezone
  tz.initializeTimeZones();

  // 2) Initialize notifications
  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  await notifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  // 3) ✅ Initialize local storage FIRST
  await LocalStorageService.init();
  
  // 4) Then initialize DI
  await di.init();

  // 5) ✅ Initialize background azan service if enabled
  try {
    final settingsJson = LocalStorageService.getAzanSettings();
    
    if (settingsJson != null && 
        settingsJson['generalEnabled'] == true && 
        settingsJson['backgroundEnabled'] == true) {
      await AzanBackgroundService.initializeService();
      print('✅ Azan background service initialized');
    }
  } catch (e) {
    print('❌ Failed to initialize azan background service: $e');
  }

  // 6) Determine initial route
  final initialRoute = LocalStorageService.isOnboardingSeen()
      ? HomeScreen.routeName
      : IntroductionAppScreen.routeName;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'ElMessiri',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE2BE7F)),
      ),
      initialRoute: initialRoute,
      routes: {
        IntroductionAppScreen.routeName: (context) => const IntroductionAppScreen(),
        HomeScreen.routeName: (context) =>  HomeScreen(),
        SuraDetailsScreen.routeName: (context) =>  SuraDetailsScreen(),
        HadethDetailsScreen.routeName: (context) => const HadethDetailsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}