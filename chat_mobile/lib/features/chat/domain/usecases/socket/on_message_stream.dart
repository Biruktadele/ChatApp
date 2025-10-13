import 'dart:async';

import '../../entities/message.dart';
import '../../repositories/chat_socket_repository.dart';

class OnMessageStream {
  final ChatSocketRepository repo;
  OnMessageStream(this.repo);

  Stream<Message> call() => repo.messages;
}
