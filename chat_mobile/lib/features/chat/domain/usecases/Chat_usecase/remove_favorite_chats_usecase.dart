import '../../entities/chat.dart';
import '../../repositories/chat_reositorie.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';

class RemoveFavoriteChatsUsecase {
  final ChatRepository repository;

  RemoveFavoriteChatsUsecase(this.repository);

  Future<Either<Failure, void>> call(int chatId) async {
    return await repository.removeFromFavorite(chatId);
  }
}

