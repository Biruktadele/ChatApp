import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/user_repository.dart';

class LogoutUserUsecase {
  final UserRepository repository;

  LogoutUserUsecase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logoutUser();
  }
}
