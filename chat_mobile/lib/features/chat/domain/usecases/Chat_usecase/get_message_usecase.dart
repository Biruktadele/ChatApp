import '../../entities/message.dart';
import '../../repositories/chat_reositorie.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';

class GetMessagesUsecase {
  final ChatRepository repository;

  GetMessagesUsecase(this.repository);

  Future<Either<Failure, List<Message>>> call(int chatId) async {
    return await repository.getMessages(chatId);
  }
}
