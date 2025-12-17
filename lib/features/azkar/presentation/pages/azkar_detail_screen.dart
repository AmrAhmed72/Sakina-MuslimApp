import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sakina/core/services/local_storage_service.dart';
import 'package:sakina/features/azkar/domain/entities/zekr.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakina/features/daily_activity/presentation/bloc/daily_activity_bloc.dart';
import 'package:sakina/features/daily_activity/presentation/bloc/daily_activity_event.dart';

class AzkarDetailScreen extends StatefulWidget {
  final String category;
  final List<Zekr>? azkar;
  final String? jsonFile;

  const AzkarDetailScreen({
    super.key,
    required this.category,
    this.azkar,
    this.jsonFile,
  });

  @override
  State<AzkarDetailScreen> createState() => _AzkarDetailScreenState();
}

class _AzkarDetailScreenState extends State<AzkarDetailScreen> {
  Map<String, int> zekrProgress = {};
  List<Zekr> loadedAzkar = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAzkar();
  }

  Future<void> _initializeAzkar() async {
    if (widget.jsonFile != null) {
      setState(() => isLoading = true);
      await _loadAzkarFromJson();
      setState(() => isLoading = false);
    } else if (widget.azkar != null) {
      loadedAzkar = widget.azkar!;
    }
    _loadProgress();
  }

  Future<void> _loadAzkarFromJson() async {
    try {
      final String response = await rootBundle.loadString(widget.jsonFile!);
      final List<dynamic> data = json.decode(response);
      loadedAzkar = data.map((item) {
        return Zekr(
          category: widget.category,
          content: item['content'] ?? '',
          count: item['count']?.toString() ?? '1',
          description: item['description'] ?? '',
          reference: item['reference'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error loading azkar: $e');
    }
  }

  void _loadProgress() {
    for (var zekr in loadedAzkar) {
      final key = '${zekr.category}_${zekr.content.hashCode}';
      zekrProgress[key] = LocalStorageService.getZekrProgress(key);
    }
    setState(() {});
  }

  void _incrementZekr(Zekr zekr) {
    final key = '${zekr.category}_${zekr.content.hashCode}';
    final targetCount = int.tryParse(zekr.count) ?? 0;
    if (targetCount <= 0) return;

    setState(() {
      zekrProgress[key] = (zekrProgress[key] ?? 0) + 1;
      if (zekrProgress[key]! > targetCount) {
        zekrProgress[key] = targetCount;
      }
    });
    LocalStorageService.saveZekrProgress(key, zekrProgress[key]!);
    // Notify DailyActivityBloc (if provided) so the activity widget updates immediately
    try {
      context.read<DailyActivityBloc>().add(LoadDailyActivityEvent());
    } catch (_) {}

    HapticFeedback.lightImpact();
  }

  void _resetProgress() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF202020),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('إعادة تعيين',
            style: GoogleFonts.elMessiri(
                color: const Color(0xFFE2BE7F), fontWeight: FontWeight.bold)),
        content: Text('هل تريد إعادة تعيين جميع العدادات؟',
            style: GoogleFonts.elMessiri(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء',
                  style: GoogleFonts.elMessiri(color: Colors.white70))),
          ElevatedButton(
            onPressed: () {
              for (var zekr in loadedAzkar) {
                final key = '${zekr.category}_${zekr.content.hashCode}';
                LocalStorageService.resetZekrProgress(key);
                zekrProgress[key] = 0;
              }
              setState(() {});
              // Notify DailyActivityBloc (if provided) to refresh activity UI
              try {
                context.read<DailyActivityBloc>().add(LoadDailyActivityEvent());
              } catch (_) {}
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE2BE7F),
                foregroundColor: const Color(0xFF202020)),
            child: Text('إعادة تعيين',
                style: GoogleFonts.elMessiri(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Color(0xFFE2BE7F)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Text(
            widget.category,
            style: GoogleFonts.elMessiri(
              color: const Color(0xFFE2BE7F),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFFE2BE7F)),
                onPressed: _resetProgress,
                tooltip: 'إعادة تعيين',
              ),
            ),
          ],
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
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE2BE7F)))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: loadedAzkar.length,
                    itemBuilder: (context, index) {
                      final zekr = loadedAzkar[index];
                      final key = '${zekr.category}_${zekr.content.hashCode}';
                      final current = zekrProgress[key] ?? 0;
                      final target = int.tryParse(zekr.count) ?? 0;
                      final isCountable = target > 0;
                      final isCompleted = isCountable && current >= target;

                      return AzkarGlassCard(
                        zekr: zekr,
                        current: current,
                        target: target,
                        isCountable: isCountable,
                        isCompleted: isCompleted,
                        onTap: () => _incrementZekr(zekr),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// IPHONE-STYLE GLASS AZKAR CARD
// ──────────────────────────────────────────────────────────────
class AzkarGlassCard extends StatelessWidget {
  final Zekr zekr;
  final int current;
  final int target;
  final bool isCountable;
  final bool isCompleted;
  final VoidCallback onTap;

  const AzkarGlassCard({
    super.key,
    required this.zekr,
    required this.current,
    required this.target,
    required this.isCountable,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isCountable ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(38),
          // شفافة: Transparent glass
          color: Colors.transparent,
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF4CAF50).withOpacity(0.6)
                : const Color(0xFFE2BE7F).withOpacity(0.5),
            width: isCompleted ? 2.2 : 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: (isCompleted
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFE2BE7F))
                  .withOpacity(0.25),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: Stack(
            children: [
              // Frosted glass overlay
              Positioned.fill(
                child: Container(color: Colors.white.withOpacity(0.1)),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // TOP LEFT: Small Circle Counter – شفاف
                    if (isCountable)
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // شفاف تمامًا
                            color: Colors.transparent,
                            border: Border.all(
                              color: isCompleted
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFE2BE7F),
                              width: 2.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isCompleted
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFE2BE7F))
                                    .withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Progress Ring (شفاف)
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  value: current / target,
                                  strokeWidth: 3.5,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  color: isCompleted
                                      ? Colors.white.withOpacity(0.8)
                                      : const Color(0xFFE2BE7F)
                                          .withOpacity(0.8),
                                ),
                              ),
                              // Count Text
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$current',
                                    style: GoogleFonts.elMessiri(
                                      color: isCompleted
                                          ? Colors.white
                                          : const Color(0xFFE2BE7F),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '/$target',
                                    style: GoogleFonts.elMessiri(
                                      color: isCompleted
                                          ? Colors.white70
                                          : const Color(0xFFE2BE7F)
                                              .withOpacity(0.8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Zekr Text
                    Center(
                      child: Text(
                        zekr.content,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.elMessiri(
                          color: Color(0xFFE2BE7F),
                          fontSize: 22,
                          height: 2.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Description
                    if (zekr.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            zekr.description,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.elMessiri(
                              color: Color(0xFFE2BE7F),
                              fontSize: 14,
                              
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Reference
                    if (zekr.reference.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          zekr.reference,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.elMessiri(
                            color: Color(0xFFE2BE7F),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],

                    // Tap Hint
                    if (isCountable && !isCompleted) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'اضغط للعد',
                          style: GoogleFonts.elMessiri(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
