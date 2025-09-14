import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class LoginUserUsecase {
  final UserRepository repository;

  LoginUserUsecase(this.repository);

  Future<Either<Failure, User>> call(User user) async {
    return await repository.loginUser(user);
  }
}