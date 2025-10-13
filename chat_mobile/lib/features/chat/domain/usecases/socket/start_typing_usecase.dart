import '../../repositories/chat_socket_repository.dart';

class StartTyping {
  final ChatSocketRepository repo;
  StartTyping(this.repo);

  Future<void> call(int chatId, int userId) => repo.startTyping(chatId, userId);
}