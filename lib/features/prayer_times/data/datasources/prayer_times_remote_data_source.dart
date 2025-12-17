import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sakina/core/error/exceptions.dart';
import 'package:sakina/core/network/api_constants.dart';
import 'package:sakina/features/prayer_times/data/models/prayer_times_model.dart';

abstract class PrayerTimesRemoteDataSource {
  Future<PrayerTimesModel> getPrayerTimes();
}

class PrayerTimesRemoteDataSourceImpl implements PrayerTimesRemoteDataSource {
  final http.Client client;

  PrayerTimesRemoteDataSourceImpl({required this.client});

  @override
  Future<PrayerTimesModel> getPrayerTimes() async {
    try {
      final now = DateTime.now();
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.timingsByCity}'
        '?city=${ApiConstants.defaultCity}'
        '&country=${ApiConstants.defaultCountry}'
        '&method=${ApiConstants.defaultMethod}'
        '&date=${now.day}-${now.month}-${now.year}',
      );

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return PrayerTimesModel.fromJson(jsonResponse);
      } else {
        throw ServerException('Failed to load prayer times');
      }
    } catch (e) {
      throw ServerException('Failed to load prayer times: $e');
    }
  }
}
