import 'package:equatable/equatable.dart';

abstract class DailyActivityEvent extends Equatable {
  const DailyActivityEvent();

  @override
  List<Object?> get props => [];
}

class LoadDailyActivityEvent extends DailyActivityEvent { const LoadDailyActivityEvent(); }

class TogglePrayerCompletedEvent extends DailyActivityEvent {
  final String prayerName;

  const TogglePrayerCompletedEvent(this.prayerName);

  @override
  List<Object?> get props => [prayerName];
}

class AddQuranProgressEvent extends DailyActivityEvent {
  final int amount;

  const AddQuranProgressEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class SetQuranProgressEvent extends DailyActivityEvent {
  final int value;

  const SetQuranProgressEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class SetQuranGoalEvent extends DailyActivityEvent {
  final int goal;

  const SetQuranGoalEvent(this.goal);

  @override
  List<Object?> get props => [goal];
}

class ResetDailyActivityEvent extends DailyActivityEvent { const ResetDailyActivityEvent(); }
