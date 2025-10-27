import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class UpdatePhotoUsecase {
  final UserRepository repository;

  UpdatePhotoUsecase(this.repository);

  Future<Either<Failure, User>> call(Uint8List photoBytes) async {
    return await repository.updatePhoto(photoBytes);
  }
}
