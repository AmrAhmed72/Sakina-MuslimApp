import 'package:equatable/equatable.dart';
import 'package:sakina/features/quran/domain/entities/verse.dart';

class Surah extends Equatable {
  final String index;
  final String name;
  final int count;
  final List<Verse> verses;

  const Surah({
    required this.index,
    required this.name,
    required this.count,
    required this.verses,
  });

  @override
  List<Object?> get props => [index, name, count, verses];
}
