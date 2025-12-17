import 'package:equatable/equatable.dart';
import 'package:sakina/features/azkar/domain/entities/zekr.dart';

abstract class AzkarState extends Equatable {
  const AzkarState();

  @override
  List<Object> get props => [];
}

class AzkarInitial extends AzkarState {}

class AzkarLoading extends AzkarState {}

class AzkarLoaded extends AzkarState {
  final List<Zekr> azkar;
  final Zekr? randomZekr;
  const AzkarLoaded(this.azkar, {this.randomZekr});

  @override
  List<Object> get props => [azkar, randomZekr ?? ''];
}

class AzkarError extends AzkarState {
  final String message;

  const AzkarError(this.message);

  @override
  List<Object> get props => [message];
}
