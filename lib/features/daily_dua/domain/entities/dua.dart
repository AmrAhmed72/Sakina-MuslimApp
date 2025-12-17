import 'package:equatable/equatable.dart';

class Dua extends Equatable {
  final int id;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;

  const Dua({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
  });

  @override
  List<Object?> get props => [id, title, arabic, transliteration, translation];
}
