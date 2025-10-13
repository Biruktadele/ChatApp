import 'dart:async';


import '../../entities/sugession.dart';
import '../../repositories/chat_socket_repository.dart';

class OnGetSuggestionsUsecase {
  final ChatSocketRepository repo;
  OnGetSuggestionsUsecase(this.repo);

  Stream<Suggestions> call() => repo.suggestions;
}
