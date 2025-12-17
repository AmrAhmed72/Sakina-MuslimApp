import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:sakina/core/error/exceptions.dart';
import 'package:sakina/features/daily_dua/data/models/dua_model.dart';

abstract class DuaLocalDataSource {
  Future<List<DuaModel>> getAllDuas();
  Future<DuaModel> getRandomDua();
}

class DuaLocalDataSourceImpl implements DuaLocalDataSource {
  @override
  Future<List<DuaModel>> getAllDuas() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/daily_dua.json');
      final List<dynamic> data = json.decode(response);

      return data.map((json) => DuaModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException('Failed to load duas: $e');
    }
  }

  @override
  Future<DuaModel> getRandomDua() async {
    try {
      final allDuas = await getAllDuas();
      if (allDuas.isEmpty) {
        throw CacheException('No duas available');
      }
      final random = Random();
      return allDuas[random.nextInt(allDuas.length)];
    } catch (e) {
      throw CacheException('Failed to get random dua: $e');
    }
  }
}
