import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';

class Chat extends Equatable {
  final int? id;
  final User? user1;
  final User? user2;
  String? lastMessage;
  int? unreadCount;
  DateTime? lastMessageTime;
  final String? avatar;

  Chat({
    this.id,
    this.user1,
    this.user2,
    this.lastMessage,
    this.unreadCount,
    this.lastMessageTime,
    this.avatar,
  });

  @override
  List<Object?> get props => [
    id,
    user1,
    user2,
    lastMessage,
    unreadCount,
    lastMessageTime,
    avatar,
  ];
}
