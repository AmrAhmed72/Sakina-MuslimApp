import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakina/features/daily_dua/data/datasources/dua_local_data_source.dart';
import 'package:sakina/features/daily_dua/presentation/bloc/dua_event.dart';
import 'package:sakina/features/daily_dua/presentation/bloc/dua_state.dart';

class DuaBloc extends Bloc<DuaEvent, DuaState> {
  final DuaLocalDataSource dataSource;

  DuaBloc({required this.dataSource}) : super(DuaInitial()) {
    on<GetRandomDuaEvent>(_onGetRandomDua);
    on<GetAllDuasEvent>(_onGetAllDuas);
  }

  Future<void> _onGetRandomDua(
    GetRandomDuaEvent event,
    Emitter<DuaState> emit,
  ) async {
    emit(DuaLoading());
    try {
      final dua = await dataSource.getRandomDua();
      emit(RandomDuaLoaded(dua));
    } catch (e) {
      emit(DuaError(e.toString()));
    }
  }

  Future<void> _onGetAllDuas(
    GetAllDuasEvent event,
    Emitter<DuaState> emit,
  ) async {
    emit(DuaLoading());
    try {
      final duas = await dataSource.getAllDuas();
      emit(AllDuasLoaded(duas));
    } catch (e) {
      emit(DuaError(e.toString()));
    }
  }
}
