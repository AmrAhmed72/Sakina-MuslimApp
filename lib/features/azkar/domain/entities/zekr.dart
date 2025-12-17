import 'package:equatable/equatable.dart';

class Zekr extends Equatable {
  final String category;
  final String count;
  final String description;
  final String reference;
  final String content;

  const Zekr({
    required this.category,
    required this.count,
    required this.description,
    required this.reference,
    required this.content,
  });

  @override
  List<Object?> get props => [category, count, description, reference, content];
}
