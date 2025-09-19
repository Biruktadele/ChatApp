import 'package:chat_mobile/features/chat/data/models/message_model.dart';
import 'package:chat_mobile/features/chat/domain/entities/chat.dart';
import 'package:chat_mobile/features/chat/domain/entities/message.dart';

abstract class RemoteDataSource {
  Future<List<Message>> getMessages(int chatId);
  Future<List<Chat>> getChats();

  Future<void> deleteMessage(int messageId , int chatId);
  // Future<void> sendMessage(Message message);
  Future<Chat> createChat(int userId);
  Future<void> deleteChat(int chatId);
}


