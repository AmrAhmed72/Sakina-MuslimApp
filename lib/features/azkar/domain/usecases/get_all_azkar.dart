import 'package:dartz/dartz.dart';
import 'package:sakina/core/error/failures.dart';
import 'package:sakina/features/azkar/domain/entities/zekr.dart';
import 'package:sakina/features/azkar/domain/repositories/azkar_repository.dart';

class GetAllAzkar {
  final AzkarRepository repository;

  GetAllAzkar(this.repository);

  Future<Either<Failure, List<Zekr>>> call() async {
    return await repository.getAllAzkar();
  }
}
