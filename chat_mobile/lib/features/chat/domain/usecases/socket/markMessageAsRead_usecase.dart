import '../../repositories/chat_socket_repository.dart';

class MarkMessageAsRead_usecase {
  final ChatSocketRepository repo;
  MarkMessageAsRead_usecase(this.repo);

  Future<void> call({required int messageId, required int chatId}) =>
      repo.markMessageAsRead(messageId, chatId);
}
