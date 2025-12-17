import 'package:equatable/equatable.dart';

abstract class DuaEvent extends Equatable {
  const DuaEvent();

  @override
  List<Object> get props => [];
}

class GetRandomDuaEvent extends DuaEvent {}

class GetAllDuasEvent extends DuaEvent {}
