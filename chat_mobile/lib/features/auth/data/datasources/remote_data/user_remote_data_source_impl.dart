import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/constant/api_constant.dart';
import '../../../domain/entities/user.dart';
import '../../models/user_model.dart';
import 'user_remote_data_source.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  // Add default headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };

  UserRemoteDataSourceImpl({required this.client, required this.secureStorage});

  static const String _tokenKey = 'auth_token';

  @override
  Future<User> getUser() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    final response = await client.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {...defaultHeaders, 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch user: ${response.body}');
    }
  }

  @override
  Future<User> registerUser(User user) async {
    final response = await client.post(
      Uri.parse('$baseUrl/signup/'),
      headers: defaultHeaders,
      body: jsonEncode(UserModel.fromEntity(user).toRegisterJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('${jsonDecode(response.body)['detail']}');
    }
  }

  @override
  Future<User> loginUser(User user) async {
    final url = Uri.parse('$baseUrl/token/');
    final requestBody = jsonEncode(UserModel.fromEntity(user).toLoginJson());

    debugPrint('🚀 Sending POST request to $url');
    debugPrint('✨ Login request body: $requestBody');

    try {
      final response = await client.post(
        url,
        headers: defaultHeaders,
        body: requestBody,
      );

      final decodedBody = jsonDecode(response.body);
      debugPrint('✅ Received response: ${response.statusCode}');
      debugPrint('✨ Login response body: $decodedBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = decodedBody['access'];

        if (token == null) {
          throw Exception('No token in login response');
        }
        await saveToken(token);
        await saveUsername(user.username!);

        // Assuming the response body itself contains the user data.
        // If user data is nested, e.g., in decodedBody['user'], adjust this.
        return UserModel.fromJson(decodedBody);
      } else {
        throw Exception('Failed to login: ${decodedBody['detail']}');
      }
    } catch (e) {
      debugPrint('❌ Exception caught in loginUser: $e');
      // Rethrowing to be handled by the repository/UI layer.
      // You could also return a custom error object here.
      throw Exception('Failed to connect to the server: $e');
    }
  }

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: _tokenKey);
  }

  // @override
  Future<void> saveUsername(String username) async {
    await secureStorage.write(key: 'username', value: username);
  }

  @override
  Future<void> saveUserId(int userId) async {
    await secureStorage.write(key: 'user_id', value: userId.toString());
  }

  @override
  Future<void> deleteToken() async {
    await secureStorage.delete(key: _tokenKey);
  }

  @override
  Future<List<User>> getAllUsers() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    final response = await client.get(
      Uri.parse('$baseUrl/users/'),
      headers: {...defaultHeaders, 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.body}');
    }
  }

  @override
  Future<User> me() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    final response = await client.get(
      Uri.parse('$baseUrl/users/me/'),
      headers: {...defaultHeaders, 'Authorization': 'Bearer $token'},
    );
      debugPrint('🪂Fetching current user: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch user: ${response.body}');
    }
  }

  @override
  Future<User> updateMe(String field, String value) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    final response = await client.patch(
      Uri.parse('$baseUrl/users/me/'),
      headers: {...defaultHeaders, 'Authorization': 'Bearer $token'},
      body: jsonEncode({field: value}),
    );
    debugPrint('🪂Updating user field ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  @override
  Future<User> updatePhoto(Uint8List photoBytes) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse('$baseUrl/users/me/'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    var file = http.MultipartFile.fromBytes(
      'avatar',
      photoBytes,
      filename: 'profile_photo.jpg',
    );

    request.files.add(file);

    var response = await request.send();

    if (response.statusCode != 200) {
      final responseBody = await response.stream.bytesToString();
      throw Exception('Failed to update photo: $responseBody');
    }
    final responseBody = await response.stream.bytesToString();
    return UserModel.fromJson(jsonDecode(responseBody));
  }
}
