import 'package:equatable/equatable.dart';


abstract class AzanEvent extends Equatable {
  const AzanEvent();

  @override
  List<Object?> get props => [];
}

class LoadAzanSettings extends AzanEvent {}

class UpdatePrayerSetting extends AzanEvent {
  final String prayerName;
  final bool? enabled;
  final double? volume;
  final bool? notificationOnly;

  const UpdatePrayerSetting({
    required this.prayerName,
    this.enabled,
    this.volume,
    this.notificationOnly,
  });

  @override
  List<Object?> get props => [prayerName, enabled, volume, notificationOnly];
}

class UpdateGeneralSetting extends AzanEvent {
  final bool? enabled;
  final bool? background;

  const UpdateGeneralSetting({
    this.enabled,
    this.background,
  });

  @override
  List<Object?> get props => [enabled, background];
}
