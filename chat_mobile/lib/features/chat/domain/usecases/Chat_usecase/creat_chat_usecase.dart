import '../../entities/chat.dart';
import '../../repositories/chat_reositorie.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';

class CreateChatUsecase {
  final ChatRepository repository;

  CreateChatUsecase(this.repository);

  Future<Either<Failure, Chat>> call(int userId) async {
    return await repository.createChat(userId);
  }
}
