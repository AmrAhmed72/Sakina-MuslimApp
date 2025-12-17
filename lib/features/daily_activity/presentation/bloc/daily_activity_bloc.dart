import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakina/core/services/local_storage_service.dart';
import 'daily_activity_event.dart';
import 'daily_activity_state.dart';

class DailyActivityBloc extends Bloc<DailyActivityEvent, DailyActivityState> {
  DailyActivityBloc() : super(DailyActivityState.initial()) {
    on<LoadDailyActivityEvent>(_onLoad);
    on<TogglePrayerCompletedEvent>(_onTogglePrayer);
    on<AddQuranProgressEvent>(_onAddQuran);
    on<SetQuranProgressEvent>(_onSetQuran);
    on<ResetDailyActivityEvent>(_onReset);
    on<SetQuranGoalEvent>(_onSetQuranGoal);
    // load initial state
    add(LoadDailyActivityEvent());
  }

  Future<void> _onLoad(LoadDailyActivityEvent event, Emitter<DailyActivityState> emit) async {
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final Map<String, bool> map = {};
    for (var p in prayers) {
      map[p] = LocalStorageService.getPrayerCompleted(p);
    }

    final q = LocalStorageService.getQuranProgress();
    final goal = LocalStorageService.getQuranGoal();

    emit(DailyActivityState(prayersCompleted: map, quranProgress: q, quranGoal: goal));
  }

  Future<void> _onTogglePrayer(TogglePrayerCompletedEvent event, Emitter<DailyActivityState> emit) async {
    final current = Map<String, bool>.from(state.prayersCompleted);
    final prev = current[event.prayerName] ?? false;
    final next = !prev;
    current[event.prayerName] = next;
    await LocalStorageService.savePrayerCompleted(event.prayerName, next);
    emit(state.copyWith(prayersCompleted: current));
  }

  Future<void> _onAddQuran(AddQuranProgressEvent event, Emitter<DailyActivityState> emit) async {
    final next = state.quranProgress + event.amount;
    await LocalStorageService.saveQuranProgress(next);
    emit(state.copyWith(quranProgress: next));
  }

  Future<void> _onSetQuran(SetQuranProgressEvent event, Emitter<DailyActivityState> emit) async {
    final v = event.value < 0 ? 0 : event.value;
    await LocalStorageService.saveQuranProgress(v);
    emit(state.copyWith(quranProgress: v));
  }

  Future<void> _onSetQuranGoal(SetQuranGoalEvent event, Emitter<DailyActivityState> emit) async {
    final goal = event.goal < 0 ? 0 : event.goal;
    await LocalStorageService.saveQuranGoal(goal);
    // emit updated goal immediately so UI updates
    emit(state.copyWith(quranGoal: goal));
  }

  Future<void> _onReset(ResetDailyActivityEvent event, Emitter<DailyActivityState> emit) async {
    await LocalStorageService.resetAllPrayerCompletions();
    await LocalStorageService.resetQuranProgress();
    // also clear per-page read markers so progress truly starts from 0
    await LocalStorageService.resetDailyQuranRead();
    // Also reset azkar progress when the user resets daily activity
    await LocalStorageService.resetAllAzkarProgress();
    // Note: Azkar progress reset is handled elsewhere (Azkar detail screen)
    final prayers = {'Fajr': false, 'Dhuhr': false, 'Asr': false, 'Maghrib': false, 'Isha': false};
    final goal = LocalStorageService.getQuranGoal();
    emit(DailyActivityState(prayersCompleted: prayers, quranProgress: 0, quranGoal: goal));
  }
}
