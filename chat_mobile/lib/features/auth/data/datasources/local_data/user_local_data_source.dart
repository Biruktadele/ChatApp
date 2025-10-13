import '../../../domain/entities/user.dart';
import '../../models/user_model.dart';

abstract class UserLocalDataSource {
  Future<void> saveUser(User user);
  Future<UserModel?> getUser();
  Future<void> deleteUser();

  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  

  Future<void> cacheUsers(List<UserModel> users);
  Future<List<UserModel>> getCachedUsers();
  Future<UserModel?> getUserById(int id);
  Future<void> updateUser(UserModel user);
  Future<void> removeUser(int user_id);
  Future<void> clearUsersCache();
}