import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class RegisterUserUsecase {
  final UserRepository repository;

  RegisterUserUsecase(this.repository);

  Future<Either<Failure, User>> call(User user) async {
    return await repository.registerUser(user);
  }
}
