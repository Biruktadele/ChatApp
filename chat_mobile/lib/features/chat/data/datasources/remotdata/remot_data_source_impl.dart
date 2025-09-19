import 'dart:convert';
import 'dart:math' as math;

import 'package:chat_mobile/core/constant/api_constatn.dart';
import 'package:chat_mobile/features/chat/data/datasources/remotdata/remot_data_source.dart';
import 'package:chat_mobile/features/chat/data/models/chat_model.dart';
import 'package:chat_mobile/features/chat/data/models/message_model.dart';
import 'package:chat_mobile/features/chat/domain/entities/chat.dart';
import 'package:chat_mobile/features/chat/domain/entities/message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RemotDataSourceImpl extends RemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  RemotDataSourceImpl({required this.client, required this.secureStorage});

  Future<Map<String, String>> _authHeaders({bool json = false}) async {
    final token = await secureStorage.read(key: 'auth_token') ?? '';
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';
    if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  @override
  Future<List<Chat>> getChats() async {
    final url = Uri.parse('$baseUrl/chats/');
    final headers = await _authHeaders();
    final response = await client.get(url, headers: headers);
    if (response.statusCode == 200) {
      try {
        // Parse the JSON response and return a list of Chat objects
        final List<dynamic> json = jsonDecode(response.body);
        final result = json
            .map((chat) => ChatModel.fromJson(chat as Map<String, dynamic>))
            .toList();
        return result;
      } catch (e, st) {
        final snippet = response.body.substring(
          0,
          math.min(300, response.body.length),
        );

        debugPrint('$st');
        rethrow;
      }
    } else {
      throw Exception(response.body);
    }
  }

  @override
  Future<List<Message>> getMessages(int chatId) async {
    final url = Uri.parse('$baseUrl/chats/$chatId/messages/');
    final headers = await _authHeaders();
    final response = await client.get(url, headers: headers);
;
    if (response.statusCode == 200) {
      // Parse the JSON response and return a list of Message objects
      try {
        final List<dynamic> json = jsonDecode(response.body);
        final result = json
            .map(
              (message) =>
                  MessageModel.fromJson(message as Map<String, dynamic>),
            )
            .toList();
        return result;
      } catch (e, st) {
        final snippet = response.body.substring(
          0,
          math.min(300, response.body.length),
        );

        debugPrint('$st');
        rethrow;
      }
    } else {
      throw Exception(response.body);
    }
  }

  @override
  Future<void> deleteMessage(int messageId, int chatId) async {
    final url = Uri.parse('$baseUrl/chats/$chatId/messages/$messageId/');
    final response = await client.delete(url, headers: await _authHeaders());

    if (response.statusCode != 204) {
      throw Exception(response.body);
    }
  }

  @override
  Future<Chat> createChat(int userId) async {
    final url = Uri.parse('$baseUrl/chats/');
    final response = await client.post(
      url,
      headers: await _authHeaders(json: true),
      body: jsonEncode({'user2_id': userId}),
    );

    debugPrint('Create chat response status: ${response.statusCode}');
    debugPrint('Create chat response body: ${userId}');
    if (response.statusCode != 201) {
      throw Exception(response.body);
    }
    else {
      // Optionally, handle the response if needed
      final Map<String, dynamic> json = jsonDecode(response.body);
      final createdChat = ChatModel.fromJson(json);
      return createdChat;
      // You can return or use the createdChat object as needed
    }
  }

  @override
  Future<void> deleteChat(int chatId) async {
    final url = Uri.parse('$baseUrl/chats/$chatId/');
    final response = await client.delete(url, headers: await _authHeaders());

    if (response.statusCode != 204) {
      throw Exception(response.body);
    }
  }
}
