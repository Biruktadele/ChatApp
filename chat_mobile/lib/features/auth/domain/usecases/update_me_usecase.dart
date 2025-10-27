import 'package:dartz/dartz.dart';

import '../../../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

final class UpdateMeUsecase {
  final UserRepository repository;

  UpdateMeUsecase(this.repository);

  Future<Either<Failure, User>> call(String field, String value) async {
    return await repository.updateMe(field, value);
  }
}
