import 'package:equatable/equatable.dart';

abstract class AzkarEvent extends Equatable {
  const AzkarEvent();

  @override
  List<Object> get props => [];
}

class GetAllAzkarEvent extends AzkarEvent {}

class GetRandomZekrEvent extends AzkarEvent {}

class GetAzkarByCategoryEvent extends AzkarEvent {
  final String category;

  const GetAzkarByCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}
