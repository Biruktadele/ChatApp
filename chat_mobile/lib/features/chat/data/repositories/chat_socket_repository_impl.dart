import 'dart:async';

import 'package:chat_mobile/features/auth/data/datasources/local_data/user_local_data_source.dart';
import 'package:chat_mobile/features/chat/data/datasources/socketio/chat_socket_service.dart';
import 'package:chat_mobile/features/chat/data/models/message_model.dart';
import 'package:chat_mobile/features/chat/domain/entities/message.dart';
import 'package:chat_mobile/features/chat/domain/repositories/chat_socket_repository.dart';

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
    await socketService.sendMessage(
      chatId: _currentChatId!,
      userId: _currentUserId!,
      message: message,
    );
  
  }
}
