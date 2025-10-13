import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/data/datasources/local_data/user_local_data_source.dart';
import '../../domain/entities/sugession.dart';
import '../datasources/socketio/chat_socket_service.dart';
import '../models/message_model.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_socket_repository.dart';

class ChatSocketRepositoryImpl implements ChatSocketRepository {
  final ChatSocketService socketService;
  final UserLocalDataSource userLocal;

  ChatSocketRepositoryImpl({
    required this.socketService,
    required this.userLocal,
  });

  int? _currentChatId;
  int? _currentUserId;
  StreamSubscription<MessageModel>? _sub;
  final _messagesCtrl = StreamController<Message>.broadcast();

  @override
  Future<void> connect({required String baseUrl, String? token}) async {
    final headers = <String, String>{};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    
    await socketService.connect(baseUrl: baseUrl, authHeaders: headers);
  }

  @override
  Future<void> disconnect() async {
    await _sub?.cancel();
    await socketService.disconnect();
    await _messagesCtrl.close();
  }

  @override
  Stream<Message> get messages => _messagesCtrl.stream;

  @override
  Stream<bool> get connection => socketService.connection;
  @override
  Stream<bool> get typing => socketService.typing;
  @override
  Stream<int> get readReceipts => socketService.readReceipts;
  @override
  Stream<Suggestions> get suggestions => socketService.suggestions;

  @override
  Future<void> joinRoom({required int chatId, required int userId}) async {
    _currentChatId = chatId;
    _currentUserId = userId;

    await socketService.joinRoom(chatId: chatId, userId: userId);

    await _sub?.cancel();
    _sub = socketService.messages.listen(_messagesCtrl.add);
  }

  @override
  Future<void> sendMessage(String message) async {
    if (_currentChatId == null || _currentUserId == null) {
      throw StateError('joinRoom must be called before sendMessage');
    }
    // debugPrint('✅Sending message: $message to chatId: $_currentChatId by userId: $_currentUserId\n\n');
    await socketService.sendMessage(
      chatId: _currentChatId!,
      userId: _currentUserId!,
      message: message,
    );
  
  }
  @override
  Future<void> startTyping(int chatId, int userId) async {
    if (_currentChatId == null || _currentUserId == null) {
      throw StateError('❌joinRoom must be called before startTyping');
    }
    // debugPrint('✅✅✅✅✅User $userId started typing in chat $chatId');
    await socketService.startTyping(chatId, userId);
  }

  @override
  Future<void> markMessageAsRead(int chatId , int messageId) async {
    if (_currentChatId == null || _currentUserId == null) {
      throw StateError('joinRoom must be called before markMessageAsRead');
    }
    // debugPrint('✅✅✅✅Marking message $messageId as read in chat $chatId');
    await socketService.markMessageAsRead(chatId , messageId);
  }
  @override
  Future<void> stopTyping(int chatId, int userId) async {
    if (_currentChatId == null || _currentUserId == null) {
      throw StateError('joinRoom must be called before stopTyping');
    }
    // debugPrint('✅ok✅✅✅User $userId stopped typing in chat $chatId');
    await socketService.stopTyping(chatId, userId);
  }
  // @override
  // Stream<bool> get typing => socketService.typing;

}
