import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/azan_settings_model.dart';

class AzanService {
  static const String _settingsKey = 'azan_settings';

  Future<AzanSettings> getAzanSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);

    if (settingsJson != null) {
      try {
        final json = jsonDecode(settingsJson);
        return AzanSettings.fromJson(json);
      } catch (e) {
        // If parsing fails, return default settings
        return AzanSettings.defaultSettings();
      }
    }

    return AzanSettings.defaultSettings();
  }

  Future<void> saveAzanSettings(AzanSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, settingsJson);
  }
}
