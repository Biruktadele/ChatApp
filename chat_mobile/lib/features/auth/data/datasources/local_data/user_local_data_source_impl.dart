import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../core/db_manager/database_helper.dart';
import '../../../domain/entities/user.dart';
import '../../models/user_model.dart';
import 'user_local_data_source.dart';

const cacheKey = 'user';
const tokenKey = 'token';

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final FlutterSecureStorage flutterSecureStorage;
  final DatabaseHelper _databaseHelper = DatabaseHelper();


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


  //User methods
  @override
  Future<void> cacheUsers(List<UserModel> users)async{
    debugPrint('✨✨✨Caching ${users} users locally.');
    await _databaseHelper.BulkInsert(
        users.map((user) => UserModel.fromEntity(user).toMap()).toList(), 'User');
  }
  @override
  Future<List<UserModel>> getCachedUsers() async {

   return await _databaseHelper.getall('User')
        .then((maps) => maps.map((map) => UserModel.fromJson(map)).toList());
  }
  @override
  Future<UserModel?> getUserById(int id) async {

    return await _databaseHelper.getById('User', id)
        .then((map) => map != null ? UserModel.fromJson(map) : null);
  }
  @override
  Future<void> updateUser(User user) async {

    await _databaseHelper.update(UserModel.fromEntity(user).toMap(), 'User');
  }
  @override
  Future<void> removeUser(int user_id) async {

    await _databaseHelper.delete('User', user_id);
  }
  @override
  Future<void> clearUsersCache() async {

    await _databaseHelper.clearTable('User');
  }


}
