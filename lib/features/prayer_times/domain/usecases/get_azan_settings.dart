import '../repositories/azan_repository.dart';
import '../../data/models/azan_settings_model.dart';

class GetAzanSettings {
  final AzanRepository repository;

  GetAzanSettings(this.repository);

  Future<AzanSettings> call() async {
    return await repository.getAzanSettings();
  }
}
