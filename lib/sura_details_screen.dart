import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sakina/models/sura_item_model.dart';

class SuraDetailsScreen extends StatefulWidget {
  static const String routeName = "SuraDetails";

  SuraDetailsScreen({super.key});

  @override
  State<SuraDetailsScreen> createState() => _SuraDetailsScreenState();
}

class _SuraDetailsScreenState extends State<SuraDetailsScreen> {
  List<String> verses = [];

  @override
  Widget build(BuildContext context) {
    var model = ModalRoute.of(context)!.settings.arguments as SuraItemModel;

    if (verses.isEmpty) {
      loadSuraFile(model.index);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Color(0xFF202020),
        title: Text(
          model.nameEn,
          style: GoogleFonts.elMessiri(color: Color(0xFFE2BE7F), fontSize: 30),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFFE2BE7F)),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF202020),
          image: DecorationImage(
            image: AssetImage("assets/images/sura_details_bg.png"),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                  child: Column(
                    children: [
                      Text(
                        model.nameAr,
                        style: GoogleFonts.elMessiri(
                            fontSize: 30, color: Color(0xFFE2BE7F)),
                      ),
                      Expanded(
                        child: ListView.separated(
                          separatorBuilder: (context, index) => Divider(
                            thickness: 2,
                            endIndent: 40,
                            indent: 40,
                            color: Color(0xFFE2BE7F),
                          ),
                          itemBuilder: (context, index) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text.rich(
                                textAlign: TextAlign.center,
                                TextSpan(children: [
                                  TextSpan(
                                    text: verses[index],
                                    style: GoogleFonts.elMessiri(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: "(${index + 1})",
                                    style: GoogleFonts.elMessiri(
                                        fontSize: 16, color: Colors.white),
                                  )
                                ])),
                          ),
                          itemCount: verses.length,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  loadSuraFile(int index) async {
    String suraFile =
        await rootBundle.loadString("assets/file/${index + 1}.txt");
    List<String> suraLines = suraFile.split("\n");
    print(suraLines);
    verses = suraLines;
    setState(() {});
  }
}
