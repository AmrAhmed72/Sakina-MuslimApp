import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sakina/core/di/injection_container.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_bloc.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_event.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_state.dart';
import 'package:sakina/features/azkar/presentation/pages/azkar_detail_screen.dart';
import 'package:sakina/features/daily_activity/presentation/bloc/daily_activity_bloc.dart';
import 'package:sakina/features/daily_activity/presentation/bloc/daily_activity_event.dart';

class AzkarTab extends StatelessWidget {
  const AzkarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AzkarBloc>()..add(GetAllAzkarEvent()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          
          child: BlocBuilder<AzkarBloc, AzkarState>(
            builder: (context, state) {
              // ─── Loading ───
              if (state is AzkarLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFD700),
                    strokeWidth: 2.5,
                  ),
                );
              }

              // ─── Loaded ───
              if (state is AzkarLoaded) {
                // Group categories (only names + count)
                final Map<String, int> categories = {};
                for (var zekr in state.azkar) {
                  if (zekr.category != 'stop') {
                    categories[zekr.category] =
                        (categories[zekr.category] ?? 0) + 1;
                  }
                }

                final categoryList = categories.keys.toList();

                // Responsive sizing using MediaQuery
                final mq = MediaQuery.of(context);
                final width = mq.size.width;

                // Breakpoints: small phones -> 1, phones/tablet ->2, large tablet ->3, desktop ->4
                final crossAxisCount = width >= 1100
                    ? 4
                    : width >= 800
                        ? 3
                        : width >= 450
                            ? 2
                            : 1;

                // Spacing scaled a bit with width
                final spacing = (width * 0.04).clamp(8.0, 24.0);

                // Card sizing and text/icon sizes
                final cardPadding = (width * 0.04).clamp(12.0, 24.0);
                final iconSize = (width * 0.08).clamp(18.0, 40.0);
                final titleFontSize = (width * 0.042).clamp(14.0, 20.0);
                final countFontSize = (width * 0.032).clamp(11.0, 14.0);

                // childAspectRatio adjusted so cards keep a pleasant height
                final childAspectRatio = (width / crossAxisCount) / (180 + (width * 0.05));

                return Padding(
                  padding: EdgeInsets.all(spacing),
                  child: GridView.builder(
                    cacheExtent: 300,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: categoryList.length,
                    itemBuilder: (context, index) {
                      final category = categoryList[index];
                      final count = categories[category]!;

                      return GlassCategoryCard(
                        title: category,
                        count: count,
                        icon: _getCategoryIcon(category),
                        onTap: () {
                          HapticFeedback.lightImpact();

                          // EXACTLY LIKE ORIGINAL CODE: Filter here
                          final categoryAzkar = state.azkar
                              .where((z) => z.category == category)
                              .toList();

                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (_) => AzkarDetailScreen(
                                category: category,
                                azkar: categoryAzkar, // List<Zekr> - TYPE SAFE
                              ),
                            ),
                          )
                              .then((_) {
                            try {
                              context
                                  .read<DailyActivityBloc>()
                                  .add(const LoadDailyActivityEvent());
                            } catch (_) {}
                          });
                        },
                        // responsive sizes
                        iconSize: iconSize,
                        titleFontSize: titleFontSize,
                        countFontSize: countFontSize,
                        contentPadding: cardPadding,
                      );
                    },
                  ),
                );
              }

              // ─── Error ───
              if (state is AzkarError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off,
                          color: Colors.white70, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'فشل الاتصال',
                        style: GoogleFonts.cairo(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        state.message,
                        style: GoogleFonts.cairo(
                            color: Colors.white54, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<AzkarBloc>().add(GetAllAzkarEvent()),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('إعادة المحاولة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: const Color(0xFF0A2B1E),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  LIGHT-WEIGHT GLASS CARD
// ──────────────────────────────────────────────────────────────
class GlassCategoryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final VoidCallback onTap;
  final double? iconSize;
  final double? titleFontSize;
  final double? countFontSize;
  final double? contentPadding;

  const GlassCategoryCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.onTap,
    this.iconSize,
    this.titleFontSize,
    this.countFontSize,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            width: 1.2,
          ),
          color: Colors.white.withOpacity(0.08),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.all(contentPadding ?? 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
              ),
              child: Icon(icon, color: const Color(0xFFFFD700), size: iconSize ?? 32),
            ),
            const SizedBox(height: 14),
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: titleFontSize ?? 16,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Count
            Text(
              '$count أذكار',
              style: GoogleFonts.cairo(
                color: const Color(0xFFFFD700),
                fontSize: countFontSize ?? 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  ICON MAPPER (add your categories here)
// ──────────────────────────────────────────────────────────────
IconData _getCategoryIcon(String category) {
  const map = {
    'أذكار الصباح': Icons.wb_sunny_outlined,
    'أذكار المساء': Icons.nights_stay_outlined,
    'أذكار الصلاة': Icons.mosque_outlined,
    'أذكار النوم': Icons.bedtime_outlined,
    'أذكار الاستيقاظ': Icons.alarm_on_outlined,
    'أذكار بعد السلام': Icons.handshake_outlined,
    'أذكار السفر': Icons.flight_takeoff_outlined,
    'أذكار الطعام': Icons.restaurant_outlined,
    'أذكار الخروج من المنزل': Icons.door_front_door_outlined,
    'أذكار الدخول إلى المنزل': Icons.login_outlined,
    'أذكار الوضوء': Icons.water_drop_outlined,
    'أذكار اللباس': Icons.checkroom_outlined,
    'أذكار الزواج': Icons.favorite_border,
    'أذكار الجنازة': Icons.sentiment_very_dissatisfied,
    'أذكار الهم والحزن': Icons.sentiment_dissatisfied,
    'أذكار تفريج الهم': Icons.sentiment_satisfied,
    'أذكار الرزق': Icons.account_balance_wallet_outlined,
    'أذكار الشفاء': Icons.local_hospital_outlined,
  };
  return map[category] ?? Icons.auto_stories;
}