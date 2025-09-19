import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async'; // Make sure you have this import
import 'package:flutter/foundation.dart';

import '../../../../../core/constant/api_constatn.dart';
import '../../../../../core/error/failure.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/repositories/chat_reositorie.dart';
import '../../../domain/repositories/chat_socket_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final ChatSocketRepository chatSocketRepository;
  StreamSubscription<Message>? _messagesSubscription; // Add this

  ChatBloc(this.chatRepository, this.chatSocketRepository) : super(ChatInitial()) {
    on<LoadChats>(_loadChats);
    on<LoadMessages>(_loadMessages);
    on<CreateChat>(_createChat);
    on<DeleteChat>(_deleteChat);
    on<DeleteMessage>(_deleteMessage);
    on<NewMessageReceivedEvent>(_onNewMessageReceived);
    on<SendMessageEvent>(_onSendMessage);
    on<ConnectSocketIoEvent>(_onConnectSocket);
    on<JoinRoomEvent>(_onJoinRoom);
     _messagesSubscription = chatSocketRepository.messages.listen((message) {
      add(NewMessageReceivedEvent(message));
    });
  }
@override
Future<void> close() {
  _messagesSubscription?.cancel();
  chatSocketRepository.disconnect(); // Also a good practice to disconnect here
  return super.close();
}
  Future<void> _loadChats(LoadChats event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    final result = await chatRepository.getChats();

    result.fold(
      (failure) => emit(ChatError(failure.toString())),
      (chats) => emit(ChatLoaded(chats)),
    );
  }

  Future<void> _loadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(const MessageLoading());

    final result = await chatRepository.getMessages(event.chatId);

    result.fold(
      (failure) => emit(ChatError(failure.toString())),
      (messages) => emit(MessagesLoaded(messages)),
    );
  }

  Future<void> _createChat(CreateChat event, Emitter<ChatState> emit) async {
    emit(const ChatCreatedLoading());

    final result = await chatRepository.createChat(event.userId);

    result.fold(
      (failure) => emit(ChatCreatedError(failure.toString())),
      (chat) => emit(ChatCreated(chat)),
    );
  }

  Future<void> _deleteChat(DeleteChat event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    final result = await chatRepository.deleteChat(event.chatId);

    result.fold(
      (failure) => emit(ChatError(failure.toString())),
      (_) => add(LoadChats()),
    );
  }

  Future<void> _deleteMessage(
    DeleteMessage event,
    Emitter<ChatState> emit,
  ) async {
    emit(const MessageLoading());

    final result = await chatRepository.deleteMessage(
      event.messageId,
      event.chatId,
    );

    result.fold(
      (failure) => emit(ChatError(failure.toString())),
      (_) => emit(const MessageDeleted()),
    );
  }

  Future<void> _onNewMessageReceived(
    NewMessageReceivedEvent event,
    Emitter<ChatState> emit,
  ) async {
  // debugPrint('\n\n\n Bloc New message received: ${event.message.content}');
    emit(NewMessageReceivedState(event.message));
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await chatSocketRepository.sendMessage(
        event.content,
      );
      emit(MessageSentSuccessState());
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
    }
  }
  Future<void> _onConnectSocket(
    ConnectSocketIoEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await chatSocketRepository.connect(baseUrl: event.baseUrl, token: event.token);
      emit(SocketConnectedState());
    } catch (e) {
      emit(SocketConnectingErrorState('Failed to connect to socket: $e'));
    }
  }

  Future<void> _onJoinRoom(
    JoinRoomEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await chatSocketRepository.joinRoom(
        chatId: event.chatId,
        userId: event.userId,
      );
      emit(SocketJoinedRoomState());
    } catch (e) {
      emit(SocketJoinedErrorState('Failed to join room: $e'));
    }
  }
}
