import '../../data/models/azan_settings_model.dart';

abstract class AzanRepository {
  Future<AzanSettings> getAzanSettings();
  Future<void> saveAzanSettings(AzanSettings settings);
}
