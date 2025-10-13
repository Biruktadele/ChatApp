import 'package:flutter/foundation.dart';

import '../../../../../core/db_manager/database_helper.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../../auth/domain/entities/user.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/entities/message.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import 'local_data_source.dart';

class LocalDataSourceImpl implements LocalDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Chat methods
  @override
  Future<void> cacheChats(List<Chat> chats) async {
    // 1. Extract all unique users from the chats
    final usersToCache = <User>{};
    for (var chat in chats) {
      if (chat.user1 != null) {
        usersToCache.add(chat.user1!);
      }
      if (chat.user2 != null) {
        usersToCache.add(chat.user2!);
      }
    }

    // 2. Cache the users in the 'user' table
    if (usersToCache.isNotEmpty) {
      await _databaseHelper.BulkInsert(
        usersToCache.map((user) => UserModel.fromEntity(user).toMap()).toList(),
        'user',
      );
    }

    // 3. Cache the chats in the 'Chat' table
    if (chats.isNotEmpty) {
      await _databaseHelper.BulkInsert(
        chats.map((chat) => ChatModel.fromEntity(chat).toMap()).toList(),
        'Chat',
      );
    }
  }

  @override
  Future<List<ChatModel>> getCachedChats() async {
    // debugPrint('✨✨✨Fetching cached chats with users.');
    final List<Map<String, dynamic>> maps = await _databaseHelper
        .getChatsWithUsers();
    // debugPrint("✨✨✨✨✨✨Fetching $maps");
    return maps.map((map) {
      final user1Map = {
        'id': map['user1_id'],
        'username': map['user1_username'],
        'email': map['user1_email'],
        'avatar': map['user1_avatar'],
        'first_name': map['user1_first_name'],
        'last_name': map['user1_last_name'],
        'bio': map['user1_bio'],
        'birthday': map['user1_birthday'],
        'gender': map['user1_gender'],
        'phone_number': map['user1_phone_number'],
        'date_joined': "",
        'last_login': "",
      };
      // Use the fromJson factory to create the UserModel
      final user1 = UserModel.fromJson(user1Map);

      // Create a map for user2 from the aliased columns
      final user2Map = {
        'id': map['user2_id'],
        'username': map['user2_username'],
        'email': map['user2_email'],
        'avatar': map['user2_avatar'],
        'first_name': map['user2_first_name'],
        'last_name': map['user2_last_name'],
        'bio': map['user2_bio'],
        'birthday': map['user2_birthday'],
        'gender': map['user2_gender'],
        'phone_number': map['user2_phone_number'],
        'date_joined': "",
        'last_login': "",
      };
      // Use the fromJson factory to create the UserModel
      final user2 = UserModel.fromJson(user2Map);

      // Create the final ChatModel
      return ChatModel.fromEntity(Chat(
        id: map['id'],
        lastMessage: map['last_message'],
        unreadCount: map['unread_count'],
        lastMessageTime: map['last_message_time'] != null
            ? DateTime.parse(map['last_message_time'])
            : null,
        avatar: map['avatar'],
        user1: user1,
        user2: user2,
      ));
    }).toList();
  }

  @override
  Future<ChatModel?> getChatById(int id) async {
    return _databaseHelper
        .getById('Chat', id)
        .then((map) => map != null ? ChatModel.fromJson(map) : null);
  }

  @override
  Future<void> removeChat(int chat_id) async {
    await _databaseHelper.delete('Chat', chat_id);
  }

  @override
  Future<void> clearChatsCache() async {
    await _databaseHelper.clearTable('Chat');
  }

  Future<void> updateChat(Chat chat) async {
    await _databaseHelper.update(ChatModel.fromEntity(chat).toMap(), 'Chat');
  }

  // Message methods
  @override
  Future<void> cacheMessages(int chatId, List<Message> messages) async {
    if (messages.isEmpty) {
      return;
    }
    debugPrint(
      'Caching ${messages.length} messages for chat ID $chatId locally.',
    );

    // 1. Extract all unique senders from the messages
    final usersToCache = <User>{};
    for (var message in messages) {
      if (message.sender != null) {
        usersToCache.add(message.sender!);
      }
    }

    // 2. Cache the new users in the 'user' table first
    if (usersToCache.isNotEmpty) {
      debugPrint('Caching ${usersToCache.length} unique users from messages.');
      await _databaseHelper.BulkInsert(
        usersToCache.map((user) => UserModel.fromEntity(user).toMap()).toList(),
        'user',
      );
    }

    // 3. Cache the messages in the 'Message' table
    debugPrint('Caching ${messages.length} messages.');
    await _databaseHelper.BulkInsert(
      messages
          .map(
            (message) => MessageModel.fromEntity(message).toMap(chatId: chatId),
          )
          .toList(),
      'Message',
    );
  }

  @override
  @override
  Future<List<MessageModel>> getCachedMessages(int chatId) async {
    debugPrint(
      '✨✨✨Fetching cached messages for chat $chatId with users and chat info.',
    );
    final List<Map<String, dynamic>> maps = await _databaseHelper
        .getMessagesWithUsers(chatId);

    return maps.map((map) {
      // 1. Reconstruct the sender's UserModel from the aliased columns
      final senderMap = {
        'id': map['sender_id'],
        'username': map['sender_username'],
        'email': map['sender_email'],
        'avatar': map['sender_avatar'],
        'first_name': map['sender_first_name'],
        'last_name': map['sender_last_name'],
        'bio': map['sender_bio'],
        'birthday': map['sender_birthday'],
        'gender': map['sender_gender'],
        'phone_number': map['sender_phone_number'],
        'date_joined': map['sender_date_joined'],
        'last_login': map['sender_last_login'],
      };
      final sender = UserModel.fromJson(senderMap);

      // 2. Reconstruct the ChatModel from the aliased columns
      final chatMap = {
        'id': map['chat_id'],
        'user1_id': map['chat_user1_id'],
        'user2_id': map['chat_user2_id'],
        'last_message': map['chat_last_message'],
        'unread_count': map['chat_unread_count'],
        'last_message_time': map['chat_last_message_time'],
        'avatar': map['chat_avatar'],
      };
      final chat = ChatModel.fromJson(chatMap);

      // 3. Reconstruct the final MessageModel with full objects
      return MessageModel(
        id: map['id'],
        content: map['content'],
        createdAt: map['timestamp'] != null
            ? DateTime.parse(map['timestamp'])
            : null,
        isRead: map['is_read'] == 1,
        chat: chat,
        sender: sender,
      );
    }).toList();
  }

  @override
  Future<MessageModel?> getMessageById(int id) async {
    return await _databaseHelper
        .getById('Message', id)
        .then((map) => map != null ? MessageModel.fromJson(map) : null);
  }

  @override
  Future<void> removeMessage(int message_id) async {
    await _databaseHelper.delete('Message', message_id);
  }

  @override
  Future<void> updateMessage(Message message) async {
    await _databaseHelper.update(
      MessageModel.fromEntity(message).toMap(),
      'Message',
    );
  }

  @override
  Future<void> clearMessagesCache() async {
    await _databaseHelper.clearTable('Message');
  }

  @override
  Future addFavoriteChat(int chatId) async {
    await _databaseHelper.addToFeverite(chatId);
  }

  @override
  Future removeFavoriteChat(int chatId) async {
    await _databaseHelper.removeFromFeverite(chatId);
  }

  @override
  Future<List<Chat>> getFavoriteChats() async {
    final res =  await _databaseHelper.getFavoriteChats();
    debugPrint('✨✨On Local Data✨✨Favorite chats from DB: $res');
    final chats = res.map((chatMap) => ChatModel.fromJson(chatMap).toEntity()).toList();
    debugPrint('✨✨On Local Data✨✨Favorite chats as Entities: $chats');
    return chats;
  }
}
