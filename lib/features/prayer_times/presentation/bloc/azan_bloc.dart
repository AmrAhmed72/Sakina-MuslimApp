import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakina/features/prayer_times/domain/usecases/get_azan_settings.dart';
import 'package:sakina/features/prayer_times/domain/usecases/save_azan_settings.dart';
import 'package:sakina/features/prayer_times/data/services/azan_background_service.dart';
import 'azan_event.dart';
import 'azan_state.dart';

class AzanBloc extends Bloc<AzanEvent, AzanState> {
  final GetAzanSettings getAzanSettings;
  final SaveAzanSettings saveAzanSettings;

  AzanBloc({
    required this.getAzanSettings,
    required this.saveAzanSettings,
  }) : super(AzanSettingsLoading()) {
    on<LoadAzanSettings>(_onLoadAzanSettings);
    on<UpdatePrayerSetting>(_onUpdatePrayerSetting);
    on<UpdateGeneralSetting>(_onUpdateGeneralSetting);
  }

  Future<void> _onLoadAzanSettings(
    LoadAzanSettings event,
    Emitter<AzanState> emit,
  ) async {
    emit(AzanSettingsLoading());
    try {
      final settings = await getAzanSettings();
      emit(AzanSettingsLoaded(settings));
    } catch (e) {
      emit(AzanSettingsError(e.toString()));
    }
  }

  Future<void> _onUpdatePrayerSetting(
    UpdatePrayerSetting event,
    Emitter<AzanState> emit,
  ) async {
    if (state is AzanSettingsLoaded) {
      final currentSettings = (state as AzanSettingsLoaded).settings;
      final updatedSettings = currentSettings.copyWith(
        prayerSettings: Map.from(currentSettings.prayerSettings)
          ..update(
            event.prayerName,
            (prayerSetting) => prayerSetting.copyWith(
              enabled: event.enabled ?? prayerSetting.enabled,
            ),
          ),
      );
      await saveAzanSettings(updatedSettings);
      emit(AzanSettingsLoaded(updatedSettings));
    }
  }

  Future<void> _onUpdateGeneralSetting(
  UpdateGeneralSetting event,
  Emitter<AzanState> emit,
) async {
  if (state is AzanSettingsLoaded) {
    final currentSettings = (state as AzanSettingsLoaded).settings;
    final updatedSettings = currentSettings.copyWith(
      generalEnabled: event.enabled ?? currentSettings.generalEnabled,
      backgroundEnabled: event.background ?? currentSettings.backgroundEnabled,
    );
    
    await saveAzanSettings(updatedSettings);
    emit(AzanSettingsLoaded(updatedSettings));

    // ✅ تشغيل أو إيقاف الخدمة
    if (updatedSettings.generalEnabled && updatedSettings.backgroundEnabled) {
      await AzanBackgroundService.initializeService();
    } else {
      await AzanBackgroundService.stopService();
    }
  }
}
}