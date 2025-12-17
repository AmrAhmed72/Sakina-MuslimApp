import 'package:equatable/equatable.dart';
import 'package:sakina/features/daily_dua/domain/entities/dua.dart';

abstract class DuaState extends Equatable {
  const DuaState();

  @override
  List<Object> get props => [];
}

class DuaInitial extends DuaState {}

class DuaLoading extends DuaState {}

class RandomDuaLoaded extends DuaState {
  final Dua dua;

  const RandomDuaLoaded(this.dua);

  @override
  List<Object> get props => [dua];
}

class AllDuasLoaded extends DuaState {
  final List<Dua> duas;

  const AllDuasLoaded(this.duas);

  @override
  List<Object> get props => [duas];
}

class DuaError extends DuaState {
  final String message;

  const DuaError(this.message);

  @override
  List<Object> get props => [message];
}
