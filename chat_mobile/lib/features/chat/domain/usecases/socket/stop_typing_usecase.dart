import '../../repositories/chat_socket_repository.dart';

class StopTyping {
  final ChatSocketRepository repo;
  StopTyping(this.repo);

  Future<void> call(int chatId, int userId) => repo.stopTyping(chatId, userId);
}