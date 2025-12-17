import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sakina/features/quran/data/models/surah_model.dart';

abstract class QuranLocalDataSource {
  Future<SurahModel> getSurah(int surahNumber);
}

class QuranLocalDataSourceImpl implements QuranLocalDataSource {
  @override
  Future<SurahModel> getSurah(int surahNumber) async {
    try {
      final String response = await rootBundle.loadString(
        'assets/quran/surah_$surahNumber.json',
      );
      final Map<String, dynamic> data = json.decode(response);
      return SurahModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load surah: $e');
    }
  }
}
