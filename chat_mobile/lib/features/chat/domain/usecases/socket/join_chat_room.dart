import 'package:chat_mobile/features/chat/domain/repositories/chat_socket_repository.dart';

class JoinChatRoom {
  final ChatSocketRepository repo;
  JoinChatRoom(this.repo);

  Future<void> call({required int chatId, required int userId}) =>
      repo.joinRoom(chatId: chatId, userId: userId);
}
