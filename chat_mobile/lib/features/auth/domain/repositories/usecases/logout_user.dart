// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';

import '../../../../../../core/error/failure.dart';
import '../user_repository.dart';

class LogoutUserUsecase {
  final UserRepository repository;

  LogoutUserUsecase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logoutUser();
  }
}
