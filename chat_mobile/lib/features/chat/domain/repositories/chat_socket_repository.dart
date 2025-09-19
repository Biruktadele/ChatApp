import 'dart:async';

import 'package:chat_mobile/features/chat/domain/entities/message.dart';

abstract class ChatSocketRepository {
  Future<void> connect({required String baseUrl, String? token});
  Future<void> disconnect();

  Future<void> joinRoom({required int chatId, required int userId});

  Future<void> sendMessage(String message);

  Stream<Message> get messages;
  Stream<bool> get connection;
}
