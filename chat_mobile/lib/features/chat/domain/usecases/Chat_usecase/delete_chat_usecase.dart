import '../../repositories/chat_reositorie.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';

class DeleteChatUsecase {
  final ChatRepository repository;

  DeleteChatUsecase(this.repository);

  Future<Either<Failure, void>> call(int chatId) async {
    return await repository.deleteChat(chatId);
  }
}
