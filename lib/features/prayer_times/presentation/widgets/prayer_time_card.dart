import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A compact, interactive card that displays a prayer name and time.
///
/// - Tapping the card provides ripple + scale feedback.
/// - When [isNext] is true the card shows a subtle highlight and a "Next" badge.
class PrayerTimeCard extends StatefulWidget {
  final String prayerName;
  final String time;
  final bool isNext;
  final VoidCallback? onTap;

  const PrayerTimeCard({
    super.key,
    required this.prayerName,
    required this.time,
    this.isNext = false,
    this.onTap,
  });

  @override
  State<PrayerTimeCard> createState() => _PrayerTimeCardState();
}

class _PrayerTimeCardState extends State<PrayerTimeCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.0,
      upperBound: 0.03,
    )..addListener(() {
        setState(() {});
      });

    if (widget.isNext) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PrayerTimeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isNext && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isNext && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.96);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = const Color(0xFF202020);
    final double pulse = _pulseController.value;
    final defaultOnTap = widget.onTap;

    return Transform.scale(
      scale: _scale + pulse,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: defaultOnTap,
          onTapDown: _onTapDown,
          onTapCancel: _onTapCancel,
          onTapUp: _onTapUp,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: baseColor.withOpacity(widget.isNext ? 1.0 : 0.78),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: widget.isNext ? 12 : 6,
                  offset: Offset(0, widget.isNext ? 6 : 3),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // text column (no clock icon)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.prayerName,
                      style: GoogleFonts.elMessiri(
                        color: const Color(0xFFE2BE7F),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.time,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.elMessiri(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// Simple shim screen to show Islamic events.
// Note: navigation to IslamicEventsScreen is handled by the parent container
// (HomePrayerTimesView). PrayerTimeCard no longer performs navigation itself.
