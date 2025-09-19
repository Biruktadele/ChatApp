import 'package:chat_mobile/features/chat/domain/entities/chat.dart';
import 'package:chat_mobile/features/chat/domain/entities/message.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Chat>>> getChats();
  Future<Either<Failure, List<Message>>> getMessages(int chatId);

  // Future<Either<Failure, void>> sendMessage(Message message);
  Future<Either<Failure, Chat>> createChat(int userId);
  Future<Either<Failure, void>> deleteChat(int chatId);
  Future<Either<Failure, void>> deleteMessage(int messageId, int chatId);
}
