import '../../domain/entities/message.dart';
import '../../domain/entities/chat.dart';
import '../../../auth/domain/entities/user.dart';

import '../../../auth/data/models/user_model.dart';
import 'chat_model.dart';

class MessageModel extends Message {
  MessageModel({
    super.id,
    super.content,
    super.sender,
    super.chat,
    super.createdAt,
    super.isRead,
  });
    factory MessageModel.fromJson(Map<String, dynamic> json) {
      bool? isReadValue;
      if (json['is_read'] is bool) {
        isReadValue = json['is_read'];
      } else if (json['is_read'] is int) {
        isReadValue = json['is_read'] == 1;
      }
      return MessageModel(
        id: json['id'] as int?,
        content: json['content'] as String?,
        sender: json['sender'] is Map<String, dynamic>
            ? UserModel.fromJson(json['sender'] as Map<String, dynamic>)
            : null,
        chat: json['chat'] is Map<String, dynamic>
            ? ChatModel.fromJson(json['chat'] as Map<String, dynamic>)
            : null,
            
        createdAt:
            json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
        isRead: isReadValue,
      );
    }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender,
      'chat': chat,
      'created_at': createdAt?.toIso8601String(),
      'is_read': isRead,
    };
  }
  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      content: message.content,
      sender: message.sender,
      chat: message.chat,
      createdAt: message.createdAt,
      isRead: message.isRead,
    );
  }
  factory MessageModel.fromSocketData(Map<String, dynamic> data) {
    return MessageModel(
      id: data['id'] as int?,
      content: data['content'] as String?,
      sender: User(id: data['sender_id'] , username: data['sender_username'] , ),
      chat: ChatModel(id: data['chat_id']),
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : null,
      isRead: data['is_read'] as bool?,
    );
  }
  Map<String, dynamic> toMap({int? chatId}) {
    return {
      'id': id,
      'chat_id': chatId ?? chat?.id, // Use passed chatId as priority
      'sender_id': sender?.id,
      'content': content,
      'timestamp': createdAt?.toIso8601String(),
      'is_read': isRead == true ? 1 : 0, // Convert boolean to integer for SQLite
    };
  }

}
