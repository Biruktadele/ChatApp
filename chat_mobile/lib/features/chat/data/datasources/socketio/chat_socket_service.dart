import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../domain/entities/sugession.dart';
import '../../models/message_model.dart';

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
  Stream<bool> get typing;
  // Stream<bool> get stopType;
  Stream<bool> get connection;
  Stream<int> get readReceipts;
  Stream<Suggestions> get suggestions;

  Future<void> startTyping(int chatId, int userId);
  Future<void> markMessageAsRead(int chatId , int messageId);
  Future<void> stopTyping(int chatId, int userId);
  
}
