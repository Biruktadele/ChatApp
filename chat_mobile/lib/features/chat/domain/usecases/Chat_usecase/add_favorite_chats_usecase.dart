import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../repositories/chat_reositorie.dart';

class AddFavoriteChatsUsecase {
  final ChatRepository repository;

  AddFavoriteChatsUsecase(this.repository);

  Future<Either<Failure, void>> call(int chatId) async {
    return await repository.addToFavorite(chatId);
  }
}

