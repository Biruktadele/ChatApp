import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../entities/chat.dart';
import '../../repositories/chat_reositorie.dart';

class GetFavoriteChatsUsecase {
  final ChatRepository repository;

  GetFavoriteChatsUsecase(this.repository);

  Future<Either<Failure, List<Chat>>> call() async {
    return await repository.getFavoriteChats();
  }
}

