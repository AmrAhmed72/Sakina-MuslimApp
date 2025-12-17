import 'package:equatable/equatable.dart';

class Verse extends Equatable {
  final int number;
  final String text;

  const Verse({
    required this.number,
    required this.text,
  });

  @override
  List<Object?> get props => [number, text];
}
