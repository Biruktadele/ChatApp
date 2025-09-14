import '../../../domain/entities/user.dart';
import '../../models/user_model.dart';

abstract class UserLocalDataSource {
  Future<void> saveUser(User user);
  Future<UserModel?> getUser();
  Future<void> deleteUser();

  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}