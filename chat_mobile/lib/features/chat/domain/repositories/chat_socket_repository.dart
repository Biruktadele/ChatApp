import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/message.dart';
import '../entities/sugession.dart';

abstract class ChatSocketRepository {
  Future<void> connect({required String baseUrl, String? token});
  Future<void> disconnect();

  Future<void> joinRoom({required int chatId, required int userId});

  Future<void> sendMessage(String message);

  Stream<Message> get messages;
  Stream<bool> get connection;
  Stream<bool> get typing;
  Stream<int> get readReceipts;
  Stream<Suggestions> get suggestions;
  // Stream<bool> get stopType;


  // Stream<bool> get online;
  // Stream<bool> get offline;
  Future<void> startTyping(int chatId, int userId);
  Future<void> markMessageAsRead(int messageId, int chatId);
  Future<void> stopTyping(int chatId, int userId);
}
