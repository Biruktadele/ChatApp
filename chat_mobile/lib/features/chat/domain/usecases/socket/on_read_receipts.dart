import 'dart:async';

import '../../repositories/chat_socket_repository.dart';

class OnReadReceipts {
  final ChatSocketRepository repo;
  OnReadReceipts(this.repo);

  Stream<int> call() => repo.readReceipts;
}