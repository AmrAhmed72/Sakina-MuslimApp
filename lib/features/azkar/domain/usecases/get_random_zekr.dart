import 'package:dartz/dartz.dart';
import 'package:sakina/core/error/failures.dart';
import 'package:sakina/features/azkar/domain/entities/zekr.dart';
import 'package:sakina/features/azkar/domain/repositories/azkar_repository.dart';

class GetRandomZekr {
  final AzkarRepository repository;

  GetRandomZekr(this.repository);

  Future<Either<Failure, Zekr>> call() async {
    return await repository.getRandomZekr();
  }
}
