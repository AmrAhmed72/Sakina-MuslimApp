import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:sakina/core/error/exceptions.dart';
import 'package:sakina/features/azkar/data/models/zekr_model.dart';

abstract class AzkarLocalDataSource {
  Future<List<ZekrModel>> getAllAzkar();
  Future<ZekrModel> getRandomZekr();
  Future<List<ZekrModel>> getAzkarByCategory(String category);
}

class AzkarLocalDataSourceImpl implements AzkarLocalDataSource {
  @override
  Future<List<ZekrModel>> getAllAzkar() async {
    try {
      final String response =
          await rootBundle.loadString('assets/file/azkar.json');
      final Map<String, dynamic> data = json.decode(response);

      List<ZekrModel> allAzkar = [];

      data.forEach((category, azkarList) {
        if (azkarList is List) {
          for (var item in azkarList) {
            if (item is Map<String, dynamic>) {
              // Skip the "stop" entry
              if (item['category'] != 'stop') {
                allAzkar.add(ZekrModel.fromJson(item));
              }
            } else if (item is List) {
              // Handle nested arrays
              for (var nestedItem in item) {
                if (nestedItem is Map<String, dynamic> &&
                    nestedItem['category'] != 'stop') {
                  allAzkar.add(ZekrModel.fromJson(nestedItem));
                }
              }
            }
          }
        }
      });

      return allAzkar;
    } catch (e) {
      throw CacheException('Failed to load azkar: $e');
    }
  }

  @override
  Future<ZekrModel> getRandomZekr() async {
    try {
      final allAzkar = await getAllAzkar();
      if (allAzkar.isEmpty) {
        throw CacheException('No azkar available');
      }
      final random = Random();
      return allAzkar[random.nextInt(allAzkar.length)];
    } catch (e) {
      throw CacheException('Failed to get random zekr: $e');
    }
  }

  @override
  Future<List<ZekrModel>> getAzkarByCategory(String category) async {
    try {
      final allAzkar = await getAllAzkar();
      return allAzkar.where((zekr) => zekr.category == category).toList();
    } catch (e) {
      throw CacheException('Failed to get azkar by category: $e');
    }
  }
}
