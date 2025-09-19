import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import 'chat.dart';


class Message extends Equatable {
  final int? id;
  final String? content;
  final User? sender;
  final Chat? chat;
  final DateTime? createdAt;
  final bool? isRead;
  
  Message({
    this.id,
    this.content,
    this.sender,
    this.chat,
    this.createdAt,
    this.isRead,
  });

  @override
  List<Object?> get props => [id, content, sender, chat, createdAt, isRead];
}
