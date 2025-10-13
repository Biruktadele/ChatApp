import '../../models/message_model.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/entities/message.dart';

abstract class RemoteDataSource {
  Future<List<Message>> getMessages(int chatId);
  Future<List<Chat>> getChats();

  Future<void> deleteMessage(int messageId , int chatId);
  // Future<void> sendMessage(Message message);
  Future<Chat> createChat(int userId);
  Future<void> deleteChat(int chatId);
  Future<void> markMessageAsRead(int messageId , int chatId);
  
}


