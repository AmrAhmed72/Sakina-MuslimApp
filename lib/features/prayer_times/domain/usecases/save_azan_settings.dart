import '../repositories/azan_repository.dart';
import '../../data/models/azan_settings_model.dart';

class SaveAzanSettings {
  final AzanRepository repository;

  SaveAzanSettings(this.repository);

  Future<void> call(AzanSettings settings) async {
    return await repository.saveAzanSettings(settings);
  }
}
