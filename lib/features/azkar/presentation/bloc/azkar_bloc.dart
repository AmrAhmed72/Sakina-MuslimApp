import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

import 'package:sakina/features/azkar/domain/usecases/get_all_azkar.dart';
import 'package:sakina/features/azkar/domain/usecases/get_random_zekr.dart';
import 'package:sakina/features/azkar/domain/entities/zekr.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_event.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_state.dart';

class AzkarBloc extends Bloc<AzkarEvent, AzkarState> {
  final GetAllAzkar getAllAzkar;
  final GetRandomZekr getRandomZekr;

  AzkarBloc({
    required this.getAllAzkar,
    required this.getRandomZekr,
  }) : super(AzkarInitial()) {
    on<GetAllAzkarEvent>(_onGetAllAzkar);
    on<GetRandomZekrEvent>(_onGetRandomZekr);
  }

  Future<void> _onGetAllAzkar(
    GetAllAzkarEvent event,
    Emitter<AzkarState> emit,
  ) async {
    emit(AzkarLoading());

    final result = await getAllAzkar();

    // Avoid passing an async closure into fold (fold executes synchronously).
    // Instead, handle success/failure with an explicit branch so we can await
    // further async operations (like getRandomZekr) without emitting after the
    // handler completed.
    result.fold(
      (failure) => emit(AzkarError(failure.message)),
      (azkar) async {},
    );

    // If successful, extract the value synchronously then continue.
    if (result.isRight()) {
      final azkar = result.getOrElse(() => <Zekr>[]);

      // Emit the list first
      emit(AzkarLoaded(azkar));

      // After list is available, request a random zekr and emit it while preserving list
      try {
        final randResult = await getRandomZekr();
        randResult.fold(
          (_) {
            // fallback: pick random from loaded list if usecase fails
            if (azkar.isNotEmpty) {
              final rnd = Random();
              final chosen = azkar[rnd.nextInt(azkar.length)];
              if (!emit.isDone) emit(AzkarLoaded(azkar, randomZekr: chosen));
            }
          },
          (zekr) {
            if (!emit.isDone) emit(AzkarLoaded(azkar, randomZekr: zekr));
          },
        );
      } catch (_) {
        if (azkar.isNotEmpty && !emit.isDone) {
          final rnd = Random();
          final chosen = azkar[rnd.nextInt(azkar.length)];
          emit(AzkarLoaded(azkar, randomZekr: chosen));
        }
      }
      return;
    }
  }

  Future<void> _onGetRandomZekr(
    GetRandomZekrEvent event,
    Emitter<AzkarState> emit,
  ) async {
    // Do not emit loading here to avoid overwriting existing list state in UI.
    final result = await getRandomZekr();

    result.fold(
      (failure) => emit(AzkarError(failure.message)),
      (zekr) {
        // Preserve existing azkar list if available
        final currentList = state is AzkarLoaded ? (state as AzkarLoaded).azkar : <Zekr>[];
        emit(AzkarLoaded(currentList, randomZekr: zekr));
      },
    );
  }
}
