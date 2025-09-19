part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

final class ChatInitial extends ChatState {}

///Chat///
final class ChatLoading extends ChatState {
  const ChatLoading();
}

final class MessageLoading extends ChatState {
  const MessageLoading();
}

final class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}

/// Load Chats ///
final class ChatLoaded extends ChatState {
  final List<Chat> chats;

  const ChatLoaded(this.chats);

  @override
  List<Object> get props => [chats];
}

//// create chat ////
final class ChatCreated extends ChatState {
  final Chat chat;

  const ChatCreated(this.chat);

  @override
  List<Object> get props => [chat];
}

final class ChatCreatedError extends ChatState {
  final String message;

  const ChatCreatedError(this.message);
  @override
  List<Object> get props => [message];
}

final class ChatCreatedLoading extends ChatState {
  const ChatCreatedLoading();
}

//// delete chat ////
final class ChatDeleted extends ChatState {
  final int chatId;

  const ChatDeleted(this.chatId);

  @override
  List<Object> get props => [chatId];
}

//// Load Messages ////
final class MessagesLoaded extends ChatState {
  final List<Message> messages;

  const MessagesLoaded(this.messages);
  @override
  List<Object> get props => [messages];
}

//// delete message ////
final class MessageDeleted extends ChatState {
  const MessageDeleted();
}

/// Socket io Statets ///

final class SocketIoConnectionState extends ChatState {
  final bool isConnected;

  const SocketIoConnectionState(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}

final class NewMessageReceivedState extends ChatState {
  final Message message;

  const NewMessageReceivedState(this.message);

  @override
  List<Object> get props => [message];
}

final class MessageSentSuccessState extends ChatState {
  const MessageSentSuccessState();

}

final class MessageSendErrorState extends ChatState {
  final String message;

  const MessageSendErrorState(this.message);

  @override
  List<Object> get props => [message];
}

final class MessageSendingState extends ChatState {
  const MessageSendingState();
}

final class SocketConnectedState extends ChatState {
  const SocketConnectedState();
}

final class SocketConnectingErrorState extends ChatState {
  final String message;

  const SocketConnectingErrorState(this.message);
}

final class SocketJoinedRoomState extends ChatState {
  const SocketJoinedRoomState();
}

final class SocketJoinedErrorState extends ChatState {
  final String message;

  const SocketJoinedErrorState(this.message);

  @override
  List<Object> get props => [message];
}
