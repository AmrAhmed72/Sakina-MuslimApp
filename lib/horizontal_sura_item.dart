import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HorizontalSuraItem extends StatelessWidget {
  final String nameAr;
  final String nameEn;
  final int index;


  const HorizontalSuraItem(
      {super.key,
      required this.index,
     
      required this.nameAr,
      required this.nameEn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
      decoration: BoxDecoration(
          color: Color(0xFFE2BE7F), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 8,
              ),
              Text(
                nameEn,
                style: GoogleFonts.elMessiri(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(
                height: 8,
              ),
              Text(nameAr,
                  style: GoogleFonts.elMessiri(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(
                height: 8,
              ),
            
            ],
          ),
          Image.asset("assets/images/quran_sura.png")
        ],
      ),
    );
  }
}
