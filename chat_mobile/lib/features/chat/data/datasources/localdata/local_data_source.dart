import '../../../domain/entities/chat.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';

abstract class LocalDataSource {
  // Chat methods
  Future<void> cacheChats(List<ChatModel> chats);
  Future<List<ChatModel>> getCachedChats();
  Future<ChatModel?> getChatById(int id);
  Future<void> updateChat(ChatModel chat);
  Future<void> removeChat(int chat_id);
  Future<void> clearChatsCache();

  // Message methods
  Future<void> cacheMessages(int chatId, List<MessageModel> messages);
  Future<List<MessageModel>> getCachedMessages(int chatId);
  Future<MessageModel?> getMessageById(int id);
  Future<void> updateMessage(MessageModel message);
  Future<void> removeMessage(int message_id);
  Future<void> clearMessagesCache();

  //Feverite methods
  Future<void> addFavoriteChat(int chatId);
  Future<void> removeFavoriteChat(int chatId);
  Future<List<Chat>> getFavoriteChats();

  //additional methods if needed
  // Future<void> clearAllCache();



}