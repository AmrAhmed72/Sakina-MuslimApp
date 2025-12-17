import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuraItem extends StatelessWidget {
  final String nameAr;
  final String nameEn;
  final int index;
  final int numOfVerses;
  final bool hasBookmark;

  const SuraItem({
    super.key,
    required this.index,
    required this.numOfVerses,
    required this.nameAr,
    required this.nameEn,
    this.hasBookmark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              "assets/images/index_ic.png",
              height: 52,
              width: 52,
            ),
            Text(
              "$index",
              style: GoogleFonts.elMessiri(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
        SizedBox(
          width: 24,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$nameEn",
                style: GoogleFonts.elMessiri(fontSize: 18, color: Colors.white),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                "$numOfVerses Verses",
                style: GoogleFonts.elMessiri(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasBookmark)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.bookmark,
                  color: Color(0xFFE2BE7F),
                  size: 20,
                ),
              ),
            Text(
              "$nameAr",
              style: GoogleFonts.elMessiri(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
