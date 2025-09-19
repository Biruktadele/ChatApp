import 'dart:async';

import 'package:chat_mobile/features/chat/data/models/message_model.dart';

import '../../../domain/entities/message.dart';

abstract class ChatSocketService {
  Future<void> connect({
    required String baseUrl,
    Map<String, String>? authHeaders,
  });
  Future<void> disconnect();

  Future<void> joinRoom({required int chatId, required int userId});
  Future<void> leaveRoom({required int chatId});

  Future<void> sendMessage({
    required int chatId,
    required int userId,
    required String message,
  });

  Stream<MessageModel> get messages;
  Stream<bool> get connection;
}
