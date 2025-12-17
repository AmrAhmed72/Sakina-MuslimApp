import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sakina/core/di/injection_container.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_bloc.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_event.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_state.dart';
import 'package:sakina/features/azkar/presentation/pages/azkar_detail_screen.dart';
import 'package:sakina/features/daily_dua/presentation/bloc/dua_bloc.dart';
import 'package:sakina/features/daily_dua/presentation/bloc/dua_event.dart';
import 'package:sakina/features/daily_dua/presentation/bloc/dua_state.dart';
import 'package:sakina/features/daily_activity/presentation/bloc/daily_activity_event.dart';
import 'package:sakina/features/daily_activity/presentation/bloc/daily_activity_bloc.dart';
import 'package:sakina/features/daily_activity/presentation/widgets/daily_activity_widget.dart';
import 'package:sakina/features/islamicEvents/islamic_events_screen';
import 'package:sakina/features/prayer_times/presentation/bloc/prayer_times_bloc.dart';
import 'package:sakina/features/prayer_times/presentation/bloc/prayer_times_event.dart';
import 'package:sakina/features/prayer_times/presentation/bloc/prayer_times_state.dart';
import 'package:sakina/features/prayer_times/presentation/pages/azan_control_screen.dart';
import 'package:sakina/features/prayer_times/presentation/widgets/prayer_time_card.dart';
import 'package:sakina/features/qibla/presentation/pages/qibla_screen.dart';

import '../../../azkar/domain/entities/zekr.dart';

class HomePrayerTimesScreen extends StatelessWidget {
  const HomePrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<PrayerTimesBloc>()..add(GetPrayerTimesEvent()),
        ),
        BlocProvider(
          create: (_) => sl<AzkarBloc>()..add(GetAllAzkarEvent()),
        ),
        BlocProvider(
          create: (_) => sl<DuaBloc>()..add(GetRandomDuaEvent()),
        ),
      ],
      child: const HomePrayerTimesView(),
    );
  }
}

class HomePrayerTimesView extends StatelessWidget {
  const HomePrayerTimesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ==================== Prayer times ====================
            BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
              builder: (context, state) {
                if (state is PrayerTimesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE2BE7F)),
                  );
                } else if (state is PrayerTimesLoaded) {
                  final prayerTimes = state.prayerTimes;

                  return Column(
                    children: [


                         Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2BE7F),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      prayerTimes.gregorianDate,
                                      style: GoogleFonts.elMessiri(
                                        color: const Color(0xFF202020),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'مواقيت الصلاة',
                                        style: GoogleFonts.elMessiri(
                                          color: const Color(0xFF202020),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Text(
                                      prayerTimes.hijriDate,
                                      style: GoogleFonts.elMessiri(
                                        color: const Color(0xFF202020),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    SizedBox(
                                        width: 85,
                                        child: PrayerTimeCard(
                                            prayerName: 'Fajr',
                                            time: prayerTimes.fajr,
                                            isNext: prayerTimes.nextPrayer ==
                                                'Fajr')),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                        width: 85,
                                        child: PrayerTimeCard(
                                            prayerName: 'Dhuhr',
                                            time: prayerTimes.dhuhr,
                                            isNext: prayerTimes.nextPrayer ==
                                                'Dhuhr')),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                        width: 85,
                                        child: PrayerTimeCard(
                                            prayerName: 'ASR',
                                            time: prayerTimes.asr,
                                            isNext: prayerTimes.nextPrayer ==
                                                'Asr')),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                        width: 85,
                                        child: PrayerTimeCard(
                                            prayerName: 'Maghrib',
                                            time: prayerTimes.maghrib,
                                            isNext: prayerTimes.nextPrayer ==
                                                'Maghrib')),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                        width: 85,
                                        child: PrayerTimeCard(
                                            prayerName: 'Isha',
                                            time: prayerTimes.isha,
                                            isNext: prayerTimes.nextPrayer ==
                                                'Isha')),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Next Pray - ${prayerTimes.nextPrayer.split('\n')[0]}',
                                    style: GoogleFonts.elMessiri(
                                      color: const Color(0xFF202020),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CountdownToNext(
                                      timeString: prayerTimes.nextPrayerTime),
                                ],
                              ),
                            ],
                          ),
                        ),

                    ],
                  );
                } else if (state is PrayerTimesLoadedFromCache) {
                  final prayerTimes = state.prayerTimes;

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AzanControlScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2BE7F),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      prayerTimes.gregorianDate,
                                      style: GoogleFonts.elMessiri(
                                        color: const Color(0xFF202020),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Pray Time',
                                        style: GoogleFonts.elMessiri(
                                          color: const Color(0xFF202020),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Text(
                                      prayerTimes.hijriDate,
                                      style: GoogleFonts.elMessiri(
                                        color: const Color(0xFF202020),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    SizedBox(
                                        width: 85,
                                        child: PrayerTimeCard(
                                            prayerName: 'Fajr',
                                            time: prayerTimes.fajr,
                                            isNext: prayerTimes.nextPrayer ==
                                                'Fajr')),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                        width: 85,
                                        child: PrayerTimeCard(
                                            prayerName: 'Dhuhr',
                                            time: prayerTimes.dhuhr,
                                            isNext: prayerTimes.nextPrayer ==
                                                'Dhuhr')),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                        width: 85,
                                        child: PrayerTimeCard(
                                            prayerName: 'ASR',
                                            time: prayerTimes.asr,
                                            isNext: prayerTimes.nextPrayer ==
                                                'Asr')),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                        width: 85,
                                        child: PrayerTimeCard(
                                            prayerName: 'Maghrib',
                                            time: prayerTimes.maghrib,
                                            isNext: prayerTimes.nextPrayer ==
                                                'Maghrib')),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                        width: 85,
                                        child: PrayerTimeCard(
                                            prayerName: 'Isha',
                                            time: prayerTimes.isha,
                                            isNext: prayerTimes.nextPrayer ==
                                                'Isha')),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Next Pray - ${prayerTimes.nextPrayer.split('\n')[0]}',
                                    style: GoogleFonts.elMessiri(
                                      color: const Color(0xFF202020),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CountdownToNext(
                                      timeString: prayerTimes.nextPrayerTime),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Offline: showing last known prayer times',
                        style: GoogleFonts.elMessiri(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  );
                } else if (state is PrayerTimesError) {
                  return Center(
                    child: Column(
                      children: [
                        Text('Error: ${state.message}',
                            style: GoogleFonts.elMessiri(color: Colors.red)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => context
                              .read<PrayerTimesBloc>()
                              .add(GetPrayerTimesEvent()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 15),

            // ==================== Qibla Direction Widget ====================
           /* Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QiblaScreen(),
                      ),
                    );
                  },
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFE2BE7F), width: 1.2),
                      ),
                      child: ImageIcon(
                        AssetImage("assets/images/compass.png"),
                        color: Color(0xFFE2BE7F),
                        size: 50,
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IslamicEventsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFE2BE7F), width: 1.2),
                    ),
                    child: Icon(
                      Icons.calendar_month_sharp,
                      color: Color(0xFFE2BE7F),
                      size: 50,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFE2BE7F), width: 1.2),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: Color(0xFFE2BE7F),
                      size: 50,
                    ),
                  ),
                ),
              ],
            ),
*/
            //const SizedBox(height: 15),

// ==================== Daily activity tracker ====================
            BlocProvider(
              create: (context) {
                // Defensive: if DI registration didn't happen for some reason,
                // fallback to creating a local bloc instance so the UI won't crash.
                if (sl.isRegistered<DailyActivityBloc>()) {
                  return sl<DailyActivityBloc>()
                    ..add(const LoadDailyActivityEvent());
                }
                final b = DailyActivityBloc();
                b.add(const LoadDailyActivityEvent());
                return b;
              },
              child: const DailyActivityWidget(),
            ),
            const SizedBox(height: 15),
            // ==================== Daily dua ====================
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('دعاء اليوم',
                    style: GoogleFonts.elMessiri(
                        color: const Color(0xFFE2BE7F),
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                const Icon(Icons.auto_awesome,
                    color: Color(0xFFE2BE7F), size: 20),
              ],
            ),
            const SizedBox(height: 12),

            BlocBuilder<DuaBloc, DuaState>(
              builder: (context, state) {
                if (state is DuaLoading) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFE2BE7F)));
                } else if (state is RandomDuaLoaded) {
                  final dua = state.dua;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFE2BE7F), Color(0xFFB18843)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(dua.title,
                            style: GoogleFonts.elMessiri(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(dua.arabic,
                                style: GoogleFonts.elMessiri(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    height: 1.5),
                                textAlign: TextAlign.center),
                          ),
                        ),
                        if (dua.translation.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('الترجمة',
                              style: GoogleFonts.elMessiri(
                                  color: Colors.black.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(dua.translation,
                              style: GoogleFonts.elMessiri(
                                  color: Colors.black.withOpacity(0.8),
                                  fontSize: 13,
                                  height: 1.6)),
                        ],
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 15),

            // ==================== Azkar header ====================
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text('أذكَار',
                        style: GoogleFonts.elMessiri(
                            color: const Color(0xFFE2BE7F),
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    const Icon(Icons.auto_awesome,
                        color: Color(0xFFE2BE7F), size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ==================== Random azkar card (provided by AzkarBloc) ====================
            BlocBuilder<AzkarBloc, AzkarState>(
              builder: (context, state) {
                if (state is AzkarLoading)
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFE2BE7F)));

                Zekr? randomZekr;
                if (state is AzkarLoaded) {
                  randomZekr = state.randomZekr;
                }

                if (randomZekr == null) return const SizedBox.shrink();

                return GestureDetector(
                  onTap: () {
                    // Navigate to the Azkar detail screen for the selected category
                    final categoryList = (state is AzkarLoaded)
                        ? state.azkar
                            .where((z) => z.category == randomZekr!.category)
                            .toList()
                        : <Zekr>[];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AzkarDetailScreen(
                          category: randomZekr!.category,
                          azkar: categoryList,
                        ),
                      ),
                    ).then((_) {
                      // Reload daily activity when returning from AzkarDetailScreen
                      try {
                        context
                            .read<DailyActivityBloc>()
                            .add(const LoadDailyActivityEvent());
                      } catch (_) {}
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFE2BE7F), Color(0xFFB18843)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                  color: const Color(0xFF202020),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text(randomZekr.count,
                                  style: GoogleFonts.elMessiri(
                                      color: const Color(0xFFE2BE7F),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Text(randomZekr.category,
                                style: GoogleFonts.elMessiri(
                                    color: const Color(0xFF202020),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(
                            child: Text(randomZekr.content,
                                style: GoogleFonts.elMessiri(
                                    color: const Color(0xFF202020),
                                    fontSize: 18,
                                    height: 1.8,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center)),
                        if (randomZekr.description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Center(
                              child: Text(randomZekr.description,
                                  style: GoogleFonts.elMessiri(
                                      color: const Color(0xFF202020)
                                          .withOpacity(0.7),
                                      fontSize: 12))),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 15),

            // ==================== Morning / Evening azkar cards ====================
            /*BlocBuilder<AzkarBloc, AzkarState>(
                        builder: (context, state) {
                          if (state is AzkarLoading) {
                            return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator(color: Color(0xFFE2BE7F))));
                          }

                          if (state is AzkarLoaded) {
                            final morningAzkar = state.azkar.where((z) => z.category == 'أذكار الصباح').toList();
                            final eveningAzkar = state.azkar.where((z) => z.category == 'أذكار المساء').toList();

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AzkarDetailScreen(
                        category: 'أذكار المساء', azkar: eveningAzkar))),
                                  child: Container(
                                    height: 250,
                                    width: 200,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: const Color(0xFFE2BE7F), width: 1), borderRadius: BorderRadius.circular(20)),
                                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                                      ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.asset("assets/images/evening_azkar.png", width: 180, height: 200, fit: BoxFit.fill)),
                                      const SizedBox(height: 8),
                                      const Text("أذكار المساء", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE2BE7F))),
                                    ]),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => AzkarDetailScreen(
                                              category: 'أذكار الصباح', azkar: morningAzkar))),
                                  child: Container(
                                    height: 250,
                                    width: 200,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: const Color(0xFFE2BE7F), width: 1), borderRadius: BorderRadius.circular(20)),
                                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                                      ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.asset("assets/images/morning_azkar.png", width: 180, height: 200, fit: BoxFit.fill)),
                                      const SizedBox(height: 8),
                                      const Text("أذكار الصباح", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE2BE7F))),
                                    ]),
                                  ),
                                ),
                              ],
                            );
                          }

                          return const SizedBox(height: 250, child: Center(child: Text('', style: TextStyle(color: Colors.transparent))));
                        },
                      ),*/
          ],
        ),
      ),
    );
  }
}

class CountdownToNext extends StatefulWidget {
  final String timeString; // expected format: 'H:MM\nAM' or 'H:MM\nPM'

  const CountdownToNext({Key? key, required this.timeString}) : super(key: key);

  @override
  State<CountdownToNext> createState() => _CountdownToNextState();
}

class _CountdownToNextState extends State<CountdownToNext> {
  late DateTime target;
  late Duration remaining;
  StreamSubscription<int>? _sub;

  @override
  void initState() {
    super.initState();
    target = _parseFormattedTime(widget.timeString);
    remaining = _computeRemaining(target);
    _sub = Stream.periodic(const Duration(seconds: 1), (i) => i).listen((_) {
      final newRem = _computeRemaining(target);
      if (mounted) setState(() => remaining = newRem);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  DateTime _parseFormattedTime(String formatted) {
    final parts = formatted.split('\n');
    final timePart = parts.isNotEmpty ? parts[0].trim() : '';
    final period = parts.length > 1 ? parts[1].trim().toUpperCase() : 'AM';
    final hm = timePart.split(':');
    int hour = int.tryParse(hm[0]) ?? 0;
    final minute = hm.length > 1 ? int.tryParse(hm[1]) ?? 0 : 0;
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  Duration _computeRemaining(DateTime t) {
    var now = DateTime.now();
    if (t.isBefore(now)) t = t.add(const Duration(days: 1));
    return t.difference(now);
  }

  String _format(Duration d) {
    if (d.isNegative) return '00:00:00';
    final h = d.inHours.remainder(24).toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _format(remaining),
      style: GoogleFonts.elMessiri(
          color: const Color(0xFF202020),
          fontSize: 14,
          fontWeight: FontWeight.w600),
    );
  }
}
