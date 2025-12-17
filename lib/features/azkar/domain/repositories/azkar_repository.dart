import 'package:dartz/dartz.dart';
import 'package:sakina/core/error/failures.dart';
import 'package:sakina/features/azkar/domain/entities/zekr.dart';

abstract class AzkarRepository {
  Future<Either<Failure, List<Zekr>>> getAllAzkar();
  Future<Either<Failure, Zekr>> getRandomZekr();
  Future<Either<Failure, List<Zekr>>> getAzkarByCategory(String category);
}
