part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}


final class LoadChats extends ChatEvent {
  const LoadChats();
}

final class LoadMessages extends ChatEvent {
  final int chatId;

  const LoadMessages(this.chatId);

  @override
  List<Object> get props => [chatId];
}

final class DeleteMessage extends ChatEvent {
  final int messageId;
  final int chatId;

  const DeleteMessage(this.messageId, this.chatId);

  @override
  List<Object> get props => [messageId, chatId];
}

final class CreateChat extends ChatEvent {
  final int userId;

  const CreateChat(this.userId);

  @override
  List<Object> get props => [userId];
}

final class DeleteChat extends ChatEvent {
  final int chatId;

  const DeleteChat(this.chatId);

  @override
  List<Object> get props => [chatId];
}


//// SocketIo Events ////
final class NewMessageReceivedEvent extends ChatEvent {
  final Message message;

  const NewMessageReceivedEvent(this.message);

  @override
  List<Object> get props => [message];
}

final class SendMessageEvent extends ChatEvent {
  final int chatId;
  final String content;

  const SendMessageEvent(this.chatId, this.content);

  @override
  List<Object> get props => [chatId, content];
}

final class ConnectSocketIoEvent extends ChatEvent {
  final String baseUrl;
  final String token;

  const ConnectSocketIoEvent({required this.baseUrl, required this.token});

  @override
  List<Object> get props => [token];
}

final class JoinRoomEvent extends ChatEvent {
  final int chatId;
  final int userId;
  const JoinRoomEvent(this.chatId, this.userId);
}