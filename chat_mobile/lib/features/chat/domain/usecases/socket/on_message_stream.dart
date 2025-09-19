import 'dart:async';

import 'package:chat_mobile/features/chat/domain/entities/message.dart';
import 'package:chat_mobile/features/chat/domain/repositories/chat_socket_repository.dart';

class OnMessageStream {
  final ChatSocketRepository repo;
  OnMessageStream(this.repo);

  Stream<Message> call() => repo.messages;
}
