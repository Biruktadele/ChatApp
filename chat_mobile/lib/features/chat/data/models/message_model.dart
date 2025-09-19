import 'package:chat_mobile/features/chat/domain/entities/message.dart';
import 'package:chat_mobile/features/chat/domain/entities/chat.dart';
import 'package:chat_mobile/features/auth/domain/entities/user.dart';

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
      isRead: json['is_read'] as bool?,
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
Message toEntity() {
  return Message(
    id: id,
    content: content,
    sender: sender,
    chat: chat,
    createdAt: createdAt,
    isRead: isRead,
  );
}

}
