
class AzanSettings {
  final bool generalEnabled;
  final bool backgroundEnabled;
  final Map<String, PrayerSetting> prayerSettings;

  AzanSettings({
    required this.generalEnabled,
    required this.backgroundEnabled,
    required this.prayerSettings,
  });

  factory AzanSettings.defaultSettings() {
    return AzanSettings(
      generalEnabled: true,
      backgroundEnabled: false,
      prayerSettings: {
        'Fajr': PrayerSetting(enabled: true),
        'Dhuhr': PrayerSetting(enabled: true),
        'Asr': PrayerSetting(enabled: true),
        'Maghrib': PrayerSetting(enabled: true),
        'Isha': PrayerSetting(enabled: true),
      },
    );
  }

  AzanSettings copyWith({
    bool? generalEnabled,
    bool? backgroundEnabled,
    Map<String, PrayerSetting>? prayerSettings,
  }) {
    return AzanSettings(
      generalEnabled: generalEnabled ?? this.generalEnabled,
      backgroundEnabled: backgroundEnabled ?? this.backgroundEnabled,
      prayerSettings: prayerSettings ?? this.prayerSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generalEnabled': generalEnabled,
      'backgroundEnabled': backgroundEnabled,
      'prayerSettings': prayerSettings.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  factory AzanSettings.fromJson(Map<String, dynamic> json) {
    return AzanSettings(
      generalEnabled: json['generalEnabled'] ?? true,
      backgroundEnabled: json['backgroundEnabled'] ?? false,
      prayerSettings: (json['prayerSettings'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, PrayerSetting.fromJson(value as Map<String, dynamic>)),
          ) ?? AzanSettings.defaultSettings().prayerSettings,
    );
  }
}

class PrayerSetting {
  final bool enabled;

  PrayerSetting({
    required this.enabled,
  });

  PrayerSetting copyWith({
    bool? enabled,
  }) {
    return PrayerSetting(
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
    };
  }

  factory PrayerSetting.fromJson(Map<String, dynamic> json) {
    return PrayerSetting(
      enabled: json['enabled'] ?? true,
    );
  }
}
