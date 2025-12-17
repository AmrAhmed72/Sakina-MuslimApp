import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sakina/core/services/local_storage_service.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_state.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_bloc.dart';
import 'package:sakina/features/daily_activity/presentation/bloc/daily_activity_bloc.dart';
import 'package:sakina/features/daily_activity/presentation/bloc/daily_activity_event.dart';
import 'package:sakina/features/daily_activity/presentation/bloc/daily_activity_state.dart';
import 'package:sakina/features/azkar/domain/entities/zekr.dart';

class DailyActivityWidget extends StatelessWidget {
  const DailyActivityWidget({super.key});

  double _percentAzkar(List<Zekr> azkar) {
    if (azkar.isEmpty) return 0.0;
    int totalTarget = 0;
    int totalDone = 0;
    for (var z in azkar) {
      final key = '${z.category}_${z.content.hashCode}';
      final target = int.tryParse(z.count) ?? 0;
      final done = LocalStorageService.getZekrProgress(key);
      totalTarget += target;
      totalDone += (done > target ? target : done);
    }
    if (totalTarget == 0) return 0.0;
    return totalDone / totalTarget;
  }

  String _getPrayerNameInArabic(String english) {
    const map = {
      'Fajr': 'الفجر',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء',
    };
    return map[english] ?? english;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header moved outside the activity container as requested
        Row(mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: Text('نشاط اليوم',
                  style: GoogleFonts.elMessiri(
                      color: const Color(0xFFE2BE7F),
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),

        BlocBuilder<DailyActivityBloc, DailyActivityState>(
          builder: (context, state) {
            return BlocBuilder<AzkarBloc, AzkarState>(
              builder: (context, aState) {
                // Get azkar list from AzkarBloc if available (reactive)
                List<Zekr> azkar = [];
                if (aState is AzkarLoaded) azkar = aState.azkar;

                final azkarPercent = _percentAzkar(azkar);
                final azkarTotal = azkar.length;
                int azkarCompletedItems = 0;
                for (var z in azkar) {
                  final key = '${z.category}_${z.content.hashCode}';
                  final target = int.tryParse(z.count) ?? 0;
                  final done = LocalStorageService.getZekrProgress(key);
                  if (target > 0 && done >= target) azkarCompletedItems++;
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2BE7F), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),

                      // Azkar progress
                      Row(
                        children: [
                          Expanded(
                            child: _ActivityTile(
                              title: 'الأذكار',
                              subtitle: '$azkarCompletedItems / $azkarTotal completed',
                              progress: azkarPercent,
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Quran progress
                          Expanded(
                            child: Builder(builder: (ctx) {
                              final goal = state.quranGoal;
                              final progressVal = goal > 0 ? (state.quranProgress / goal).clamp(0.0, 1.0) : 0.0;
                              final color = progressVal >= 1.0 ? Colors.green : const Color(0xFFE2BE7F);
                              return _ActivityTile(
                                title: 'القرآن',
                                subtitle: '${state.quranProgress} / $goal pages',
                                progress: progressVal,
                                color: color,
                                onTap: () {},
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Prayers row
                      Row(
                        children: state.prayersCompleted.keys.map((p) {
                          final done = state.prayersCompleted[p] ?? false;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => context.read<DailyActivityBloc>().add(TogglePrayerCompletedEvent(p)),
                              child: Container(
                                margin: const EdgeInsets.symmetric
                                  (horizontal: 2),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                    color: done ? const Color(0xFF4CAF50) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2BE7F))),
                                child: Column(
                                  children: [
                                    Text(_getPrayerNameInArabic(p),
                                        style: GoogleFonts.elMessiri(
                                            color: done ? Colors.white : const Color(0xFFE2BE7F),
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Icon(done ? Icons.check_circle : Icons.circle_outlined,
                                        color: done ? Colors.white : const Color(0xFFE2BE7F), size: 18),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('هدف القراءة: ${state.quranGoal} صفحات', style: GoogleFonts.elMessiri(color: Colors.white70)),
                          const SizedBox(width: 12),
                          // Edit Quran goal (not the current progress)
                          IconButton(
                            onPressed: () async {
                              final controller = TextEditingController(text: state.quranGoal.toString());
                              final result = await showDialog<int?>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('تعديل هدف القراءة (صفحات)', style: GoogleFonts.elMessiri()),
                                  content: TextField(
                                    controller: controller,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(hintText: 'Pages'),
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء', style: GoogleFonts.elMessiri())),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, int.tryParse(controller.text) ?? state.quranGoal),
                                      child: Text('حفظ', style: GoogleFonts.elMessiri()),
                                    ),
                                  ],
                                ),
                              );
                              if (result != null) {
                                context.read<DailyActivityBloc>().add(SetQuranGoalEvent(result));
                              }
                            },
                            icon: const Icon(Icons.edit, color: Color(0xFFE2BE7F)),
                          ),

                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => context.read<DailyActivityBloc>().add(const ResetDailyActivityEvent()),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE2BE7F), foregroundColor: const Color(0xFF202020)),
                            child: Icon(Icons.refresh,),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final VoidCallback onTap;
  final Color? color;

  const _ActivityTile({required this.title, required this.subtitle, required this.progress, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
        child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color ?? const Color(0xFFE2BE7F)),
        ),
        child: Column(
          children: [
            Text(title, style: GoogleFonts.elMessiri(color: color ?? const Color(0xFFE2BE7F), fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle, style: GoogleFonts.elMessiri(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress, color: color ?? const Color(0xFFE2BE7F), backgroundColor: Colors.white12),
          ],
        ),
      ),
    );
  }
}
