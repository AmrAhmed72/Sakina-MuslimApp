import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sakina/hadeth_details_screen.dart';
import 'package:sakina/models/hadeth_model.dart';

class AhadethTab extends StatefulWidget {
  const AhadethTab({super.key});

  @override
  State<AhadethTab> createState() => _AhadethTabState();
}

class _AhadethTabState extends State<AhadethTab> {
  late Future<List<HadethModel>> _hadethFuture;

  @override
  void initState() {
    super.initState();
    _hadethFuture = loadHadethFile();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:  Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'الأحاديث النبوية',
            style: GoogleFonts.cairo(
              color: const Color(0xFFE2BE7F),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        
        ),
        body: Container(
         
          child: FutureBuilder<List<HadethModel>>(
            future: _hadethFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFE2BE7F),
                    strokeWidth: 3,
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    snapshot.hasError ? 'فشل تحميل الأحاديث' : 'لا توجد أحاديث',
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 18),
                  ),
                );
              }

              final ahadeth = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ahadeth.length,
                itemBuilder: (context, index) {
                  final hadith = ahadeth[index];
                  return HadithTitleCard(
                    hadith: hadith,
                    index: index + 1,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<List<HadethModel>> loadHadethFile() async {
    final String data = await rootBundle.loadString("assets/file/ahadeth.txt");
    final List<String> allAhadeth = data.split("#");

    return allAhadeth.map((h) {
      final lines = h.trim().split("\n");
      if (lines.isEmpty) return null;
      final title = lines[0];
      final content = lines.sublist(1);
      return HadethModel(title, content);
    }).whereType<HadethModel>().toList();
  }
}

// ──────────────────────────────────────────────────────────────
// GLASS HADITH TITLE CARD
// ──────────────────────────────────────────────────────────────
class HadithTitleCard extends StatelessWidget {
  final HadethModel hadith;
  final int index;

  const HadithTitleCard({
    super.key,
    required this.hadith,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(
          context,
          HadethDetailsScreen.routeName,
          arguments: hadith,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Number Circle
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2BE7F),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFF0A2B1E),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Title + Preview
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hadith.title,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hadith.content.isNotEmpty
                          ? hadith.content[0].trim()
                          : 'لا يوجد نص',
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Arrow
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFE2BE7F),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}