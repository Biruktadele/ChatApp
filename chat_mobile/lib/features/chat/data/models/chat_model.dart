import 'package:chat_mobile/features/auth/domain/entities/user.dart';
import 'package:chat_mobile/features/chat/domain/entities/chat.dart';
import 'package:flutter/foundation.dart';

import '../../../auth/data/models/user_model.dart';

class ChatModel extends Chat {
  ChatModel({
    int id = 0,
    User? user1,
    User? user2,
    String? lastMessage,
    int? unreadCount,
    DateTime? lastMessageTime,
    String? avatar,
    
  }) : super(
         id: id,
         user1: user1,
         user2: user2,
         lastMessage: lastMessage,
         unreadCount: unreadCount,
         lastMessageTime: lastMessageTime,
         avatar: avatar,
       );
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as int,
      // Backend returns full user objects; use username for display
      user1: (json['user1'] is Map<String, dynamic>)
          ? UserModel.fromJson(json['user1'] as Map<String, dynamic>)
          : null,
      user2: (json['user2'] is Map<String, dynamic>)
          ? UserModel.fromJson(json['user2'] as Map<String, dynamic>)
          : null,
      lastMessage: json['last_message'] as String?,
      unreadCount: json['unread_count'] as int?,
      lastMessageTime: _parseLastMessageTime(
        json['last_message_time'] as String?,
      ),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1': user1,
      'user2': user2,
      'last_message': lastMessage,
      'unread_count': unreadCount,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'avatar': avatar,
    };
  }

  factory ChatModel.fromEntity(Chat chat) {
    return ChatModel(
      id: chat.id ?? 0,
      user1: chat.user1,
      user2: chat.user2,
      lastMessage: chat.lastMessage,
      unreadCount: chat.unreadCount,
      lastMessageTime: chat.lastMessageTime,
      avatar: chat.avatar,
    );
  }

  // Backend provides 'YYYY-MM-DD HH:MM'; make parsing robust
  static DateTime? _parseLastMessageTime(String? value) {
    if (value == null) return null;
    try {
      // Try direct parse first
      final direct = DateTime.tryParse(value);
      if (direct != null) return direct;
      // Normalize to ISO-like: add seconds if missing and replace space with 'T'
      var normalized = value.replaceFirst(' ', 'T');
      if (RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$').hasMatch(normalized)) {
        normalized = '${normalized}:00';
      }
      return DateTime.tryParse(normalized);
    } catch (_) {
      return null;
    }
  }
}
