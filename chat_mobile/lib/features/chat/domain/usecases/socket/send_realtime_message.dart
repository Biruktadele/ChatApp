import '../../repositories/chat_socket_repository.dart';

class SendRealtimeMessage {
  final ChatSocketRepository repo;
  SendRealtimeMessage(this.repo);

  Future<void> call(String message) => repo.sendMessage(message);
}
