import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});
  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaDirection;
  double? _deviceHeading;
  Position? _position;
  bool _isLoading = true;
  String? _error;
  StreamSubscription<CompassEvent>? _compassSub;

  static const double _kaabaLat = 21.4225;
  static const double _kaabaLon = 39.8262;

  @override
  void initState() {
    super.initState();
    _initQibla();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  Future<void> _initQibla() async {
    try {
      setState(() => _isLoading = true);

      await _requestLocation();
      _position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _qiblaDirection = _calcQibla(_position!.latitude, _position!.longitude);

      final stream = FlutterCompass.events;
      if (stream == null) throw 'البوصلة غير مدعومة';

      _compassSub = stream.listen((event) {
        if (mounted && event.heading != null && event.heading != 0.0) {
          setState(() => _deviceHeading = event.heading);
        }
      });

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _requestLocation() async {
    var status = await Permission.location.status;
    if (!status.isGranted) status = await Permission.location.request();
    if (!status.isGranted) throw 'مطلوب إذن الموقع';
  }

  double _calcQibla(double lat, double lon) {
    final lat1 = lat * math.pi / 180, lon1 = lon * math.pi / 180;
    final lat2 = _kaabaLat * math.pi / 180, lon2 = _kaabaLon * math.pi / 180;
    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    var bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202020),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE2BE7F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('اتجاه القبلة',
            style: GoogleFonts.elMessiri(color: const Color(0xFFE2BE7F), fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE2BE7F)))
          : _error != null
              ? _errorWidget()
              : _compassWidget(),
    );
  }

  Widget _errorWidget() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFE2BE7F), size: 60),
            const SizedBox(height: 16),
            Text('حدث خطأ', style: GoogleFonts.elMessiri(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _initQibla,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE2BE7F)),
              child: Text('إعادة المحاولة', style: GoogleFonts.elMessiri(color: const Color(0xFF202020), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

  Widget _compassWidget() {
    final heading = _deviceHeading ?? 0.0;
    final isFacingQibla = (_qiblaDirection! - heading).abs() % 360 < 12;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // تعليمات بسيطة جدًا
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE2BE7F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2BE7F).withOpacity(0.3)),
            ),
            child: Text(
              'استدر حتى تكون الإبرة الذهبية في الأعلى',
              style: GoogleFonts.elMessiri(color: Colors.white70, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),

          // البوصلة
          SizedBox(
            height: 350,
            width: 350,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // خلفية البوصلة (تدور)
                Transform.rotate(
                  angle: -heading * (math.pi / 180),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(colors: [Color(0xFF202020), Color(0xFF303030)]),
                      border: Border.all(color: const Color(0xFFE2BE7F), width: 4),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFE2BE7F).withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                      ],
                    ),
                    child: _compassFace(),
                  ),
                ),

                // إبرة القبلة (ثابتة) ← هذه هي القبلة
                Transform.rotate(
                  angle: _qiblaDirection! * (math.pi / 180),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2BE7F),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: const Color(0xFFE2BE7F).withOpacity(0.6), blurRadius: 20, spreadRadius: 5),
                          ],
                        ),
                        child: const Icon(Icons.location_on, color: Color(0xFF202020), size: 32),
                      ),
                      Container(
                        width: 6,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFE2BE7F), Color(0xFFB18843)],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),

                // دائرة خضراء عند التصحيح
                if (isFacingQibla)
                  Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 6),
                      boxShadow: [
                        BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 30, spreadRadius: 10),
                      ],
                    ),
                  ),

                // نقطة المركز
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2BE7F),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF202020), width: 2),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // رسالة حالة
          AnimatedOpacity(
            opacity: isFacingQibla ? 1.0 : 0.7,
            duration: const Duration(milliseconds: 400),
            child: Text(
              isFacingQibla ? 'أنت تواجه القبلة' : 'استدر ببطء',
              style: GoogleFonts.elMessiri(
                color: isFacingQibla ? Colors.green : Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _compassFace() => Stack(
        children: [
          // علامات الدرجات
          ...List.generate(36, (i) {
            final angle = i * 10.0;
            final isMain = angle % 90 == 0;
            final isMid = angle % 30 == 0;
            return Transform.rotate(
              angle: angle * math.pi / 180,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: isMain ? 3 : (isMid ? 2 : 1),
                  height: isMain ? 20 : (isMid ? 15 : 10),
                  color: isMain ? const Color(0xFFE2BE7F) : Colors.white54,
                ),
              ),
            );
          }),
          // N فقط
          const Positioned(
            top: 15,
            left: 0,
            right: 0,
            child: Center(
              child: Text('N', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20)),
            ),
          ),
        ],
      );
}