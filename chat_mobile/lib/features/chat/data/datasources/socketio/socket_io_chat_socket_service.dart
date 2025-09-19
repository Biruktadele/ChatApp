import 'dart:async';

import 'package:chat_mobile/features/chat/data/datasources/socketio/chat_socket_service.dart';
import 'package:chat_mobile/features/chat/data/models/message_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../../core/constant/api_constatn.dart';
import '../../../domain/entities/message.dart';

class SocketIoChatSocketService implements ChatSocketService {
  IO.Socket? _socket;
  final _messagesCtrl = StreamController<MessageModel>.broadcast();
  final _connectionCtrl = StreamController<bool>.broadcast();

  @override
  Stream<MessageModel> get messages => _messagesCtrl.stream;

  @override
  Stream<bool> get connection => _connectionCtrl.stream;

  @override
  Future<void> connect({
    String? baseUrl,
    Map<String, String>? authHeaders,
  }) async {
    if (_socket != null) return;

    _socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .enableReconnection()
          .setExtraHeaders(authHeaders ?? {})
          .build(),
    );

    _socket!.onConnect((_) => _connectionCtrl.add(true));
    _socket!.onDisconnect((_) => _connectionCtrl.add(false));

    _socket!.on('message', (data) {
      if (data is Map<String, dynamic>) {
        debugPrint('\n\n\n Received message: ${data.toString()}');
        _messagesCtrl.add(MessageModel.fromJson(data));
      } else if (data is Map) {
        debugPrint('Received message: ${data.toString()}');

        _messagesCtrl.add(
          MessageModel.fromJson(Map<String, dynamic>.from(data)),
        );
      }
    });

    // also map error events if needed
    _socket!.onError((data) => _connectionCtrl.add(false));
    _socket!.onReconnect((_) => _connectionCtrl.add(true));

    // Ensure the connection attempt actually starts
    _socket!.connect();
  }

  @override
  Future<void> disconnect() async {
    _socket?.dispose();
    _socket = null;
  }

  @override
  Future<void> joinRoom({required int chatId, required int userId}) async {
    _socket?.emit('join', {'chat_id': chatId, 'user_id': userId});
  }

  @override
  Future<void> leaveRoom({required int chatId}) async {
    // socket.io has no default leave by chatId on client; server should manage rooms by sid
    // If server exposes a leave event, emit here. For now, no-op.
  }

 @override

Future<void> sendMessage({
  required int chatId,
  required int userId,
  required String message,
}) async {
  final completer = Completer<Message>();
  _socket?.emitWithAck('send_message', {
    'chat_id': chatId,
    'user_id': userId,
    'message': message,
  }, ack: (data) {
    if (data == true) {
      debugPrint('Message sent successfully');
      } else {
      completer.completeError('Failed to send message');
    }
  });
 
}
}
