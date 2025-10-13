import '../../entities/chat.dart';
import '../../repositories/chat_reositorie.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';

class GetChatsUsecase {
  final ChatRepository repository;

  GetChatsUsecase(this.repository);

  Future<Either<Failure, List<Chat>>> call() async {
    return await repository.getChats();
  }
}
