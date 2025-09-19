import '../../../domain/entities/user.dart';

abstract class UserRemoteDataSource {
  Future<User> getUser();
  Future<User> registerUser(User user);
  Future<User> loginUser(User user);
  Future<List<User>> getAllUsers();

  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}
