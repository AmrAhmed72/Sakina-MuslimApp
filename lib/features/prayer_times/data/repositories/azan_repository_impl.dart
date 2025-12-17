import '../../domain/repositories/azan_repository.dart';
import '../models/azan_settings_model.dart';
import '../services/azan_service.dart';

class AzanRepositoryImpl implements AzanRepository {
  final AzanService service;

  AzanRepositoryImpl(this.service);

  @override
  Future<AzanSettings> getAzanSettings() async {
    return await service.getAzanSettings();
  }

  @override
  Future<void> saveAzanSettings(AzanSettings settings) async {
    return await service.saveAzanSettings(settings);
  }
}
