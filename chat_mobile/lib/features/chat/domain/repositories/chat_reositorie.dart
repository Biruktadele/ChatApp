import '../entities/chat.dart';
import '../entities/message.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Chat>>> getChats();
  Future<Either<Failure, List<Message>>> getMessages(int chatId);

  // Future<Either<Failure, void>> sendMessage(Message message);
  Future<Either<Failure, Chat>> createChat(int userId);
  Future<Either<Failure, void>> deleteChat(int chatId);
  Future<Either<Failure, void>> deleteMessage(int messageId, int chatId);

  // New methods for favorite chats
  Future<Either<Failure, List<Chat>>> getFavoriteChats();
  Future<Either<Failure, void>> addToFavorite(int chatId);
  Future<Either<Failure, void>> removeFromFavorite(int chatId);


  // // #offline support
  // //chat repository
  // Future<Either<Failure, List<Chat>>> getCachedChats();
  // Future<Either<Failure, Chat?>> getChatById(int id);
  // Future<Either<Failure, void>> updateChat(Chat chat);
  // Future<Either<Failure, void>> removeChat(int chat_id);
  // Future<Either<Failure, void>> clearChatsCache();

  // //message repository     
  //   Future<Either<Failure, List<Message>>> getCachedMessages(int chatId);
  //   Future<Either<Failure, Message?>> getMessageById(int id);
  //   Future<Either<Failure, void>> updateMessage(Message message);
  //   Future<Either<Failure, void>> removeMessage(int message_id);
  //   Future<Either<Failure, void>> clearMessagesCache();
  
}
