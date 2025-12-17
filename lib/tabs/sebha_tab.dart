import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sakina/core/services/local_storage_service.dart';

class SebhaTab extends StatefulWidget {
  const SebhaTab({super.key});

  @override
  State<SebhaTab> createState() => _SebhaTabState();
}

class _SebhaTabState extends State<SebhaTab> {
  int counter = 0;
  int phraseIndex = 0;
  double rotationTurns = 0;
  int dailyGoal = 100;
  int dailyCount = 0;

  final List<String> phrases = [
    "سبحان الله",
    "الحمد لله",
    "الله أكبر",
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await LocalStorageService.checkAndResetDaily();
    setState(() {
      dailyGoal = LocalStorageService.getSebhaGoal();
      dailyCount = LocalStorageService.getSebhaCount();
    });
  }

  void _incrementCounter() {
    setState(() {
      counter++;
      dailyCount++;
      if (counter > 33) {
        counter = 1;
        phraseIndex = (phraseIndex + 1) % phrases.length;
      }

      rotationTurns += 1 / 12;
      LocalStorageService.saveSebhaCount(dailyCount);
    });
  }

  void _resetDailyCount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202020),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'إعادة تعيين',
          style: TextStyle(color: Color(0xFFE2BE7F)),
        ),
        content: const Text(
          'هل تريد إعادة تعيين العداد اليومي؟',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                dailyCount = 0;
                counter = 0;
                phraseIndex = 0;
              });
              LocalStorageService.resetSebhaCount();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE2BE7F),
              foregroundColor: const Color(0xFF202020),
            ),
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }

  void _setGoal() {
    final controller = TextEditingController(text: dailyGoal.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202020),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'تحديد الهدف اليومي',
          style: TextStyle(color: Color(0xFFE2BE7F)),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'الهدف',
            labelStyle: const TextStyle(color: Color(0xFFE2BE7F)),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFE2BE7F)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFE2BE7F), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newGoal = int.tryParse(controller.text) ?? 100;
              if (newGoal > 0) {
                setState(() {
                  dailyGoal = newGoal;
                });
                LocalStorageService.saveSebhaGoal(newGoal);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE2BE7F),
              foregroundColor: const Color(0xFF202020),
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ناخد حجم الشاشة
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final progress =
        dailyGoal > 0 ? (dailyCount / dailyGoal).clamp(0.0, 1.0) : 0.0;
    final isGoalReached = dailyCount >= dailyGoal;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Daily Goal Progress
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE2BE7F).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE2BE7F),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                              onTap: _resetDailyCount,
                              child: Icon(
                                Icons.refresh,
                                color: Color(0xFFE2BE7F),size: 24,
                              )),
                          SizedBox(width: 5,),
                          GestureDetector(
                            onTap: _setGoal,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2BE7F),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Color(0xFF202020),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'تعديل',
                                    style: TextStyle(
                                      color: Color(0xFF202020),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                      Text(
                        'الهدف اليومي',
                        style: GoogleFonts.elMessiri(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFE2BE7F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: const Color(0xFF202020),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isGoalReached
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFE2BE7F),
                            ),
                            minHeight: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$dailyCount / $dailyGoal',
                        style: TextStyle(
                          color: isGoalReached
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFE2BE7F),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (isGoalReached) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'أحسنت! تم إنجاز الهدف اليومي',
                          style: GoogleFonts.elMessiri(
                            textStyle: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              "سَبِّحِ اسْمَ رَبِّكَ الأَعْلَى",
              style: GoogleFonts.elMessiri(
                textStyle: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            GestureDetector(
              onTap: _incrementCounter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // sebha head فوق
                  Image.asset(
                    'assets/images/sebha_head.png',
                    width: screenWidth * 0.3,
                  ),
                  // sebha body تحت
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedRotation(
                        turns: rotationTurns,
                        duration: const Duration(milliseconds: 400),
                        child: Image.asset(
                          'assets/images/sebha_body.png',
                          width: screenWidth * 0.75,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Column(
                        children: [
                          Text(
                            phrases[phraseIndex],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "$counter",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            // Reset Button
          ],
        ),
      ),
    );
  }
}
