import 'package:sakina/features/azkar/domain/entities/zekr.dart';

class ZekrModel extends Zekr {
  const ZekrModel({
    required super.category,
    required super.count,
    required super.description,
    required super.reference,
    required super.content,
  });

  factory ZekrModel.fromJson(Map<String, dynamic> json) {
    return ZekrModel(
      category: json['category'] ?? '',
      count: json['count']?.toString() ?? '',
      description: json['description'] ?? '',
      reference: json['reference'] ?? '',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'count': count,
      'description': description,
      'reference': reference,
      'content': content,
    };
  }
}
