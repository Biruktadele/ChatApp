import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../../../core/constant/api_constatn.dart';
import '../../../../../core/error/failure.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/sugession.dart';
import '../../models/message_model.dart';
import '../../models/sugession_model.dart';
import 'chat_socket_service.dart';

class SocketIoChatSocketService implements ChatSocketService {
  IO.Socket? _socket;
  final _messagesCtrl = StreamController<MessageModel>.broadcast();
  final _connectionCtrl = StreamController<bool>.broadcast();
  final _typingCtrl = StreamController<bool>.broadcast();
  final _readReceiptsCtrl = StreamController<int>.broadcast();
  final _suggestionsCtrl = StreamController<Suggestions>.broadcast();

  @override
  Stream<MessageModel> get messages => _messagesCtrl.stream;

  @override
  Stream<bool> get typing => _typingCtrl.stream;

  @override
  Stream<int> get readReceipts => _readReceiptsCtrl.stream;
  @override
  Stream<Suggestions> get suggestions => _suggestionsCtrl.stream;

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
        debugPrint('Received message: ${data.toString()}');
        _messagesCtrl.add(MessageModel.fromSocketData(data));
      } else if (data is Map) {
        _messagesCtrl.add(
          MessageModel.fromSocketData(Map<String, dynamic>.from(data)),
        );
      }
    });
    _socket!.on('suggestions_event', (data) {
      try {
        if (data == null) return;

        dynamic suggestionsData = data;
        // The server might be wrapping the response in a map.
        if (data is Map && data.containsKey('suggestions')) {
          suggestionsData = data['suggestions'];
        }

        if (suggestionsData is Map) {
          // Already a map, just ensure it's the correct type.
          final mapData = Map<String, dynamic>.from(suggestionsData);
          debugPrint(
            '🏵️🛼 Received suggestions_event as map: ${mapData.toString()}',
          );
          _suggestionsCtrl.add(SugessionModeal.fromSocketData(mapData));
        } else if (suggestionsData is String) {
          // It's a string, so we need to clean and parse it.
          debugPrint(
            '🏵️🛼 Received suggestions_event as raw string: $suggestionsData',
          );

          // 1. Find the start and end of the JSON object.
          final startIndex = suggestionsData.indexOf('{');
          final endIndex = suggestionsData.lastIndexOf('}');

          if (startIndex != -1 && endIndex != -1) {
            // 2. Extract the JSON substring.
            final jsonString = suggestionsData.substring(
              startIndex,
              endIndex + 1,
            );

            // 3. Decode the clean JSON string.
            final Map<String, dynamic> jsonData = jsonDecode(jsonString);

            debugPrint('🏵️🛼 Parsed suggestions_event from string: $jsonData');
            _suggestionsCtrl.add(SugessionModeal.fromSocketData(jsonData));
          } 
        } else {
          debugPrint(
            '❌ Unhandled data format for suggestions_event: $suggestionsData',
          );
        }
      } catch (e) {
        debugPrint('❌ Error processing suggestions_event: $e');  
      }
    });
    _socket!.on('connected', (data) {
      debugPrint('Socket connected event: ${data.toString()}');
    });
    _socket!.on('stop_typing', (data) {
      _typingCtrl.add(false);
    });
    _socket!.on('typing', (data) {
      _typingCtrl.add(true);
    });
    _socket!.on('message_read', (data) {
      _readReceiptsCtrl.add(data['message_id']);
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
    _socket?.emitWithAck(
      'send_message',
      {'chat_id': chatId, 'user_id': userId, 'message': message},
      ack: (data) {
        if (data == true) {
          debugPrint(
            '\n\n\n\nMessage sent successfully ${chatId}, $userId, $message\n\n\n\ndata: ${data.toString()}',
          );
        } else {
          completer.completeError('Failed to send message');
        }
      },
    );
  }

  @override
  @override
  Future<bool> markMessageAsRead(int chatId, int messageId) async {
    final completer = Completer<bool>();
    _socket?.emitWithAck(
      'mark_as_read',
      {'chat_id': chatId, 'message_id': messageId},
      ack: (data) {
        if (data == true) {
          debugPrint('✅ Message marked as read: $messageId');
          completer.complete(true);
        } else {
          debugPrint('❌ Failed to mark message as read: $messageId');
          completer.complete(false);
        }
      },
    );
    return completer.future;
  }

  @override
  Future<bool> startTyping(int chatId, int userId) async {
    final completer = Completer<bool>();
    _socket?.emitWithAck(
      'start_typing',
      {'chat_id': chatId, 'user_id': userId},
      ack: (data) {
        if (data == true) {
          debugPrint('✅ User started typing in chat: $chatId');
          completer.complete(true);
        } else {
          debugPrint('❌ Failed to start typing in chat: $chatId');
          completer.complete(false);
        }
      },
    );
    return completer.future;
  }

  @override
  Future<bool> stopTyping(int chatId, int userId) async {
    final completer = Completer<bool>();
    _socket?.emitWithAck(
      'stop_typing',
      {'chat_id': chatId, 'user_id': userId},
      ack: (data) {
        if (data == true) {
          debugPrint('✅ User Stop typing in chat: $chatId');
          completer.complete(true);
        } else {
          debugPrint('❌ Failed to Stop typing in chat: $chatId');
          completer.complete(false);
        }
        debugPrint('✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅ User Stop typing in chat: $data');
      },
    );

    return completer.future;
  }
}
