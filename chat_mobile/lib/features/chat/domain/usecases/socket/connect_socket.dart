import 'package:chat_mobile/features/auth/data/datasources/local_data/user_local_data_source.dart';
import 'package:chat_mobile/features/chat/domain/repositories/chat_socket_repository.dart';

class ConnectSocket {
  final ChatSocketRepository repo;
  final UserLocalDataSource userLocal;

  ConnectSocket(this.repo, this.userLocal);

  Future<void> call(String baseUrl) async {
    final token = await userLocal.getToken();
    await repo.connect(baseUrl: baseUrl, token: token);
  }
}
