import 'package:equatable/equatable.dart';
import 'package:sakina/features/prayer_times/data/models/azan_settings_model.dart';


abstract class AzanState extends Equatable {
  const AzanState();

  @override
  List<Object?> get props => [];
}

class AzanSettingsLoading extends AzanState {}

class AzanSettingsLoaded extends AzanState {
  final AzanSettings settings;

  const AzanSettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class AzanSettingsError extends AzanState {
  final String message;

  const AzanSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
