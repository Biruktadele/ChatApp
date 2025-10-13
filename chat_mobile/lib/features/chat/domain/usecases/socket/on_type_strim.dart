import 'dart:async';

import '../../repositories/chat_socket_repository.dart';

class OnTypeStream {
  final ChatSocketRepository repo;
  OnTypeStream(this.repo);

  Stream<bool> call() => repo.typing;
}