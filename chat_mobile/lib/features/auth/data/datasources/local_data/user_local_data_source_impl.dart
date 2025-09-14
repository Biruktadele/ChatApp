import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/entities/user.dart';
import '../../models/user_model.dart';
import 'user_local_data_source.dart';

const cacheKey = 'user';
const tokenKey = 'token';

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final FlutterSecureStorage flutterSecureStorage;

  UserLocalDataSourceImpl({required this.flutterSecureStorage});

  @override
  Future<void> saveUser(User user) async {
    final jsonString = jsonEncode(UserModel.fromEntity(user).toJson());
    await flutterSecureStorage.write(key: cacheKey, value: jsonString);
  }

  @override
  Future<UserModel?> getUser() async {
    final jsonString = await flutterSecureStorage.read(key: cacheKey);
    if (jsonString != null) {
      final decode = jsonDecode(jsonString);
      return UserModel.fromJson(decode);
    }
    else{
      return throw Exception('User not found');
    }
    
  }

  @override
  Future<void> deleteUser() async {
    await flutterSecureStorage.delete(key: cacheKey);
  }

  @override
  Future<void> saveToken(String token) async {
    await flutterSecureStorage.write(key: tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    final token = await flutterSecureStorage.read(key: tokenKey);
    if (token == null) {
      return null;
    }
    return token;
  }

  @override
  Future<void> deleteToken() async {
    await flutterSecureStorage.delete(key: tokenKey);
  }
}
