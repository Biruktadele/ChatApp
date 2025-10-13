import '../../repositories/chat_reositorie.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';

class DeleteMessageUsecase {
  final ChatRepository repository;

  DeleteMessageUsecase(this.repository);

  Future<Either<Failure, void>> call(int messageId, int chatId) async {
    return await repository.deleteMessage(messageId, chatId);
  }
}
