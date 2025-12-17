import 'package:equatable/equatable.dart';

class DailyActivityState extends Equatable {
  final Map<String, bool> prayersCompleted;
  final int quranProgress; // arbitrary units (pages/sections)
  final int quranGoal;

  const DailyActivityState({required this.prayersCompleted, required this.quranProgress, required this.quranGoal});

  factory DailyActivityState.initial() => const DailyActivityState(prayersCompleted: {}, quranProgress: 0, quranGoal: 20);

  DailyActivityState copyWith({Map<String, bool>? prayersCompleted, int? quranProgress, int? quranGoal}) {
    return DailyActivityState(
      prayersCompleted: prayersCompleted ?? this.prayersCompleted,
      quranProgress: quranProgress ?? this.quranProgress,
      quranGoal: quranGoal ?? this.quranGoal,
    );
  }

  @override
  List<Object?> get props => [prayersCompleted, quranProgress, quranGoal];
}
