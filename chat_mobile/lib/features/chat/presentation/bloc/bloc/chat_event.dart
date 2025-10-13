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
final class NewTypingEvent extends ChatEvent {
  final bool isTyping;
  const NewTypingEvent(this.isTyping);
  @override
  List<Object> get props => [isTyping];
}
final class NewReadReceiptEvent extends ChatEvent {
  final int messageid;
  const NewReadReceiptEvent(this.messageid);
  @override
  List<Object> get props => [messageid];
}

final class SendMessageEvent extends ChatEvent {
  // final int chatId;
  final String content;
  // final int userId;

  const SendMessageEvent( this.content);

  @override
  List<Object> get props => [content];
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

final class StartTypingEvent extends ChatEvent {
  final int chatId;
  final int userId;
  const StartTypingEvent(this.chatId, this.userId);
}

final class StopTypingEvent extends ChatEvent {
  final int chatId;
  final int userId;
  const StopTypingEvent(this.chatId, this.userId);
}

final class MarkMessageAsReadEvent extends ChatEvent {
  final int chatId;
  final int messageId;
  const MarkMessageAsReadEvent(this.chatId , this.messageId);
}
final class NewSuggestionEvent extends ChatEvent {
  final Suggestions suggestion;
  const NewSuggestionEvent(this.suggestion);
}

final class LoadFavoriteChats extends ChatEvent {

  const LoadFavoriteChats();
}
final class RemoveFavoriteChat extends ChatEvent {
  final int chatId;
  const RemoveFavoriteChat(this.chatId);
}
class AddFavoriteChat extends ChatEvent {
  final int chatId;
  const AddFavoriteChat(this.chatId);

}
