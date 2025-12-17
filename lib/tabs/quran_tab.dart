import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sakina/core/services/local_storage_service.dart';
import 'package:sakina/features/quran/presentation/pages/quran_reader_screen.dart';
import 'package:sakina/horizontal_sura_item.dart';
import 'package:sakina/sura_item.dart';

class QuranTab extends StatefulWidget {
  QuranTab({super.key});

  @override
  State<QuranTab> createState() => _QuranTabState();
}

class _QuranTabState extends State<QuranTab> {
  String searchQuery = '';
  List<int> recentlyViewedIndices = [];
  Map<int, int> bookmarks = {};

  @override
  void initState() {
    super.initState();
    _loadRecentlyViewed();
    _loadBookmarks();
  }

  void _loadRecentlyViewed() {
    setState(() {
      recentlyViewedIndices = LocalStorageService.getRecentlyViewedSurahs();
    });
  }

  void _loadBookmarks() {
    setState(() {
      bookmarks = LocalStorageService.getAllBookmarks();
    });
  }

  void _addToRecentlyViewed(int index) {
    LocalStorageService.addRecentlyViewedSurah(index);
    _loadRecentlyViewed();
  }

  List<int> _getFilteredIndices() {
    if (searchQuery.isEmpty) {
      return List.generate(suraNames.length, (index) => index);
    }
    
    List<int> filtered = [];
    for (int i = 0; i < suraNames.length; i++) {
      if (suraNames[i].contains(searchQuery) || 
          suraNamesEn[i].toLowerCase().contains(searchQuery.toLowerCase())) {
        filtered.add(i);
      }
    }
    return filtered;
  }

  List<int> numOfVerses = [
    7,
    286,
    200,
    176,
    120,
    165,
    206,
    75,
    129,
    109,
    123,
    111,
    43,
    52,
    99,
    128,
    111,
    110,
    98,
    135,
    112,
    78,
    118,
    64,
    77,
    227,
    93,
    88,
    69,
    60,
    34,
    30,
    73,
    54,
    45,
    83,
    182,
    88,
    75,
    85,
    54,
    53,
    89,
    59,
    37,
    35,
    38,
    29,
    18,
    45,
    60,
    49,
    62,
    55,
    78,
    96,
    29,
    22,
    24,
    13,
    14,
    11,
    11,
    18,
    12,
    12,
    30,
    52,
    52,
    44,
    28,
    28,
    20,
    56,
    40,
    31,
    50,
    40,
    46,
    42,
    29,
    19,
    36,
    25,
    22,
    17,
    19,
    26,
    30,
    20,
    15,
    21,
    11,
    8,
    8,
    19,
    5,
    8,
    8,
    11,
    11,
    8,
    3,
    9,
    5,
    4,
    7,
    3,
    6,
    3,
    5,
    4,
    5,
    6
  ];
  List<String> suraNames = [
    "الفاتحه",
    "البقرة",
    "آل عمران",
    "النساء",
    "المائدة",
    "الأنعام",
    "الأعراف",
    "الأنفال",
    "التوبة",
    "يونس",
    "هود",
    "يوسف",
    "الرعد",
    "إبراهيم",
    "الحجر",
    "النحل",
    "الإسراء",
    "الكهف",
    "مريم",
    "طه",
    "الأنبياء",
    "الحج",
    "المؤمنون",
    "النّور",
    "الفرقان",
    "الشعراء",
    "النّمل",
    "القصص",
    "العنكبوت",
    "الرّوم",
    "لقمان",
    "السجدة",
    "الأحزاب",
    "سبأ",
    "فاطر",
    "يس",
    "الصافات",
    "ص",
    "الزمر",
    "غافر",
    "فصّلت",
    "الشورى",
    "الزخرف",
    "الدّخان",
    "الجاثية",
    "الأحقاف",
    "محمد",
    "الفتح",
    "الحجرات",
    "ق",
    "الذاريات",
    "الطور",
    "النجم",
    "القمر",
    "الرحمن",
    "الواقعة",
    "الحديد",
    "المجادلة",
    "الحشر",
    "الممتحنة",
    "الصف",
    "الجمعة",
    "المنافقون",
    "التغابن",
    "الطلاق",
    "التحريم",
    "الملك",
    "القلم",
    "الحاقة",
    "المعارج",
    "نوح",
    "الجن",
    "المزّمّل",
    "المدّثر",
    "القيامة",
    "الإنسان",
    "المرسلات",
    "النبأ",
    "النازعات",
    "عبس",
    "التكوير",
    "الإنفطار",
    "المطفّفين",
    "الإنشقاق",
    "البروج",
    "الطارق",
    "الأعلى",
    "الغاشية",
    "الفجر",
    "البلد",
    "الشمس",
    "الليل",
    "الضحى",
    "الشرح",
    "التين",
    "العلق",
    "القدر",
    "البينة",
    "الزلزلة",
    "العاديات",
    "القارعة",
    "التكاثر",
    "العصر",
    "الهمزة",
    "الفيل",
    "قريش",
    "الماعون",
    "الكوثر",
    "الكافرون",
    "النصر",
    "المسد",
    "الإخلاص",
    "الفلق",
    "الناس"
  ];
  List<String> suraNamesEn = [
    "Al-Fatiha",
    "Al-Baqarah",
    "Aal-E-Imran",
    "An-Nisa",
    "Al-Ma'idah",
    "Al-An'am",
    "Al-A'raf",
    "Al-Anfal",
    "At-Tawbah",
    "Yunus",
    "Hud",
    "Yusuf",
    "Ar-Ra'd",
    "Ibrahim",
    "Al-Hijr",
    "An-Nahl",
    "Al-Isra",
    "Al-Kahf",
    "Maryam",
    "Ta-Ha",
    "Al-Anbiya",
    "Al-Hajj",
    "Al-Mu'minun",
    "An-Nur",
    "Al-Furqan",
    "Ash-Shu'ara",
    "An-Naml",
    "Al-Qasas",
    "Al-Ankabut",
    "Ar-Rum",
    "Luqman",
    "As-Sajda",
    "Al-Ahzab",
    "Saba",
    "Fatir",
    "Ya-Sin",
    "As-Saffat",
    "Sad",
    "Az-Zumar",
    "Ghafir",
    "Fussilat",
    "Ash-Shura",
    "Az-Zukhruf",
    "Ad-Dukhan",
    "Al-Jathiyah",
    "Al-Ahqaf",
    "Muhammad",
    "Al-Fath",
    "Al-Hujurat",
    "Qaf",
    "Adh-Dhariyat",
    "At-Tur",
    "An-Najm",
    "Al-Qamar",
    "Ar-Rahman",
    "Al-Waqi'ah",
    "Al-Hadid",
    "Al-Mujadila",
    "Al-Hashr",
    "Al-Mumtahina",
    "As-Saff",
    "Al-Jumu'ah",
    "Al-Munafiqun",
    "At-Taghabun",
    "At-Talaq",
    "At-Tahrim",
    "Al-Mulk",
    "Al-Qalam",
    "Al-Haqqah",
    "Al-Ma'arij",
    "Nuh",
    "Al-Jinn",
    "Al-Muzzammil",
    "Al-Muddaththir",
    "Al-Qiyamah",
    "Al-Insan",
    "Al-Mursalat",
    "An-Naba",
    "An-Nazi'at",
    "Abasa",
    "At-Takwir",
    "Al-Infitar",
    "Al-Mutaffifin",
    "Al-Inshiqaq",
    "Al-Buruj",
    "At-Tariq",
    "Al-A'la",
    "Al-Ghashiyah",
    "Al-Fajr",
    "Al-Balad",
    "Ash-Shams",
    "Al-Lail",
    "Ad-Duhaa",
    "Ash-Sharh",
    "At-Tin",
    "Al-Alaq",
    "Al-Qadr",
    "Al-Bayyina",
    "Az-Zalzalah",
    "Al-Adiyat",
    "Al-Qari'ah",
    "At-Takathur",
    "Al-Asr",
    "Al-Humazah",
    "Al-Fil",
    "Quraish",
    "Al-Ma'un",
    "Al-Kawthar",
    "Al-Kafirun",
    "An-Nasr",
    "Al-Masad",
    "Al-Ikhlas",
    "Al-Falaq",
    "An-Nas"
  ];

  @override
  Widget build(BuildContext context) {
    final filteredIndices = _getFilteredIndices();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFEFFE8)),
            decoration: InputDecoration(
                hintText: "Sura Name",
                filled: true,
                fillColor: Color(0xFF202020).withOpacity(.7),
                hintStyle: GoogleFonts.elMessiri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFEFFE8)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Color(0xFFE2BE7F))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Color(0xFFE2BE7F))),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Color(0xFFE2BE7F))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Color(0xFFE2BE7F))),
                prefixIcon: Image.asset("assets/images/prefix_ic.png"),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Color(0xFFE2BE7F)),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Most Recently",
            style: GoogleFonts.elMessiri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFEFFE8)),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        if (recentlyViewedIndices.isNotEmpty)
          Container(
            height: 110,
            margin: EdgeInsets.only(left: 20),
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(
                width: 16,
              ),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final suraIndex = recentlyViewedIndices[index];
                return GestureDetector(
                  onTap: () {
                    _addToRecentlyViewed(suraIndex);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuranReaderScreen(
                          surahNumber: suraIndex + 1,
                          surahNameAr: suraNames[suraIndex],
                          surahNameEn: suraNamesEn[suraIndex],
                        ),
                      ),
                    );
                  },
                  child: HorizontalSuraItem(
                    index: suraIndex + 1,
                    nameAr: suraNames[suraIndex],
                    nameEn: suraNamesEn[suraIndex],
                   
                  ),
                );
              },
              itemCount: recentlyViewedIndices.length,
            ),
          )
        else
          Container(
            height: 150,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                'لا توجد سور تم عرضها مؤخراً',
                style: GoogleFonts.elMessiri(
                  fontSize: 14,
                  color: Color(0xFFFEFFE8).withOpacity(0.6),
                ),
              ),
            ),
          ),
        SizedBox(
          height: 8,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Suras List",
            style: GoogleFonts.elMessiri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFEFFE8)),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: filteredIndices.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد نتائج',
                      style: GoogleFonts.elMessiri(
                        fontSize: 16,
                        color: Color(0xFFFEFFE8).withOpacity(0.6),
                      ),
                    ),
                  )
                : ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                      indent: 64,
                      endIndent: 64,
                      color: Colors.white,
                      thickness: 1,
                    ),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final suraIndex = filteredIndices[index];
                      final hasBookmark = bookmarks.containsKey(suraIndex + 1);
                      
                      return GestureDetector(
                        onTap: () async {
                          _addToRecentlyViewed(suraIndex);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuranReaderScreen(
                                surahNumber: suraIndex + 1,
                                surahNameAr: suraNames[suraIndex],
                                surahNameEn: suraNamesEn[suraIndex],
                              ),
                            ),
                          );
                          // Reload bookmarks when returning
                          _loadBookmarks();
                        },
                        child: SuraItem(
                          index: suraIndex + 1,
                          nameAr: suraNames[suraIndex],
                          nameEn: suraNamesEn[suraIndex],
                          numOfVerses: numOfVerses[suraIndex],
                          hasBookmark: hasBookmark,
                        ),
                      );
                    },
                    itemCount: filteredIndices.length,
                  ),
          ),
        )
      ],
    );
  }
}
