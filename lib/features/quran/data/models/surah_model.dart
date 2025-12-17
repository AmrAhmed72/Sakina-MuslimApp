import 'package:sakina/features/quran/domain/entities/surah.dart';
import 'package:sakina/features/quran/domain/entities/verse.dart';

class SurahModel extends Surah {
  const SurahModel({
    required super.index,
    required super.name,
    required super.count,
    required super.verses,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> verseMap = json['verse'] as Map<String, dynamic>;
    
    List<Verse> verses = [];
    verseMap.forEach((key, value) {
      // Extract verse number from key (e.g., "verse_1" -> 1)
      final verseNumber = int.parse(key.split('_')[1]);
      
      // Skip verse_0 (Basmala) as it's not counted as a verse
      if (verseNumber == 0) return;
      
      verses.add(Verse(
        number: verseNumber,
        text: value as String,
      ));
    });

    // Sort verses by number
    verses.sort((a, b) => a.number.compareTo(b.number));

    return SurahModel(
      index: json['index'] as String,
      name: json['name'] as String,
      count: json['count'] as int,
      verses: verses,
    );
  }
}
