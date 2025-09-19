import 'package:chat_mobile/features/chat/domain/entities/chat.dart';
import 'package:chat_mobile/features/chat/domain/repositories/chat_reositorie.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';

class GetChatsUsecase {
  final ChatRepository repository;

  GetChatsUsecase(this.repository);

  Future<Either<Failure, List<Chat>>> call() async {
    return await repository.getChats();
  }
}
