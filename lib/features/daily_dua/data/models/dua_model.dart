import 'package:sakina/features/daily_dua/domain/entities/dua.dart';

class DuaModel extends Dua {
  const DuaModel({
    required super.id,
    required super.title,
    required super.arabic,
    required super.transliteration,
    required super.translation,
  });

  factory DuaModel.fromJson(Map<String, dynamic> json) {
    return DuaModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      arabic: json['arabic'] ?? '',
      transliteration: json['transliteration'] ?? '',
      translation: json['translation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'arabic': arabic,
      'transliteration': transliteration,
      'translation': translation,
    };
  }
}
