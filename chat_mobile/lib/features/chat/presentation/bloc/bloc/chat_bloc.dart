import 'dart:async'; // Make sure you have this import

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/chat.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/sugession.dart';
import '../../../domain/repositories/chat_reositorie.dart';
import '../../../domain/repositories/chat_socket_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final ChatSocketRepository chatSocketRepository;
  StreamSubscription<Message>? _messagesSubscription; // Add this
  StreamSubscription<bool>? _typingSubscription;
  StreamSubscription<int>? _readReceiptsSubscription;
  StreamSubscription<Suggestions>? _suggestionsSubscription;

  ChatBloc(this.chatRepository, this.chatSocketRepository)
    : super(ChatInitial()) {
    on<LoadChats>(_loadChats);
    on<LoadMessages>(_loadMessages);
    on<CreateChat>(_createChat);
    on<DeleteChat>(_deleteChat);
    on<DeleteMessage>(_deleteMessage);
    on<NewMessageReceivedEvent>(_onNewMessageReceived);
    on<SendMessageEvent>(_onSendMessage);
    on<ConnectSocketIoEvent>(_onConnectSocket);
    on<JoinRoomEvent>(_onJoinRoom);
    on<StartTypingEvent>(_onStartTyping);
    on<StopTypingEvent>(_onStopTyping);
    on<MarkMessageAsReadEvent>(_onMarkMessageAsRead);
    on<NewTypingEvent>(_onNewTyping);
    on<NewReadReceiptEvent>(_onNewReadReceipt);
    on<NewSuggestionEvent>(_onNewSuggestion);
    on<LoadFavoriteChats>(_loadFavoriteChats);
    on<AddFavoriteChat>(_addFavoriteChat);
    on<RemoveFavoriteChat>(_removeFavoriteChat);

    _messagesSubscription = chatSocketRepository.messages.listen((message) {
      add(NewMessageReceivedEvent(message));
    });
    _typingSubscription = chatSocketRepository.typing.listen((isTyping) {
      add(NewTypingEvent(isTyping));
    });
    _readReceiptsSubscription = chatSocketRepository.readReceipts.listen((readReceipts) {
      add(NewReadReceiptEvent(readReceipts));
    });
    _suggestionsSubscription = chatSocketRepository.suggestions.listen((suggestions) {
      add(NewSuggestionEvent(suggestions));
    });
  }
  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    chatSocketRepository
        .disconnect(); // Also a good practice to disconnect here
    return super.close();
  }

  Future<void> _loadChats(LoadChats event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    final result = await chatRepository.getChats();
    debugPrint('✨✨✨✨Fetched chats: $result');
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
      (_) => add(const LoadChats()),
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
  Future<void> _onNewSuggestion(
    NewSuggestionEvent event,
    Emitter<ChatState> emit,
  )
  async {
    debugPrint('\n\n\n ✅✅✅✅✅Bloc New suggestion received: ${event.suggestion}');
    emit(NewSuggestionsState(event.suggestion));
  }

  Future<void> _onNewTyping(
    NewTypingEvent event,
    Emitter<ChatState> emit,
  )
  async {
    emit(NewTypingState(event.isTyping));
  }
  Future<void> _onNewReadReceipt(
    NewReadReceiptEvent event,
    Emitter<ChatState> emit,
  )
  async {
    emit(NewReadReceiptState(event.messageid));
  }


  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await chatSocketRepository.sendMessage(
        event.content,
        // event.chatId
      );
      emit(const MessageSentSuccessState());
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
    }
  }

  Future<void> _onConnectSocket(
    ConnectSocketIoEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await chatSocketRepository.connect(
        baseUrl: event.baseUrl,
        token: event.token,
      );
      emit(const SocketConnectedState());
    } catch (e) {
      emit(SocketConnectingErrorState('Failed to connect to socket: $e'));
    }
  }

  Future<void> _onJoinRoom(JoinRoomEvent event, Emitter<ChatState> emit) async {
    try {
      await chatSocketRepository.joinRoom(
        chatId: event.chatId,
        userId: event.userId,
      );
      emit(const SocketJoinedRoomState());
    } catch (e) {
      emit(SocketJoinedErrorState('Failed to join room: $e'));
    }
  }

  Future<void> _onStartTyping(
    StartTypingEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await chatSocketRepository.startTyping(
        event.chatId,
        event.userId,
      );
      emit(const StartTypingState());
    } catch (e) {
      emit(ChatError('Failed to send typing event: $e'));
    }
  }

  Future<void> _onStopTyping(
    StopTypingEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await chatSocketRepository.stopTyping(
        event.chatId,
        event.userId,
      );
      emit(const StopTypingState());
    } catch (e) {
      emit(ChatError('Failed to stop typing event: $e'));
    }
  }

  Future<void> _onMarkMessageAsRead(
    MarkMessageAsReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await chatSocketRepository.markMessageAsRead(
        event.chatId,
        event.messageId,
      );
      emit(MakeMessageReadState(event.chatId));
    } catch (e) {
      emit(ChatError('Failed to mark message as read: $e'));
    }
  }
  Future<void> _loadFavoriteChats(LoadFavoriteChats event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    final result = await chatRepository.getFavoriteChats();
    debugPrint('✨✨✨✨Fetched favorite chats: $result');
    result.fold(
      (failure) => emit(ChatError(failure.toString())),
      (chats) => emit(ChatLoaded(chats)),
    );
  }
  Future<void> _addFavoriteChat(AddFavoriteChat event, Emitter<ChatState> emit) async {
    // You might want to pass chatId in the event
    emit(const ChatLoading());

    final result = await chatRepository.addToFavorite(event.chatId);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to add favorite chat: ${failure.toString()}');
        emit(ChatError(failure.toString()));
      },
      
      (chat) => {
        debugPrint('✨✨✨✨Successfully added to favorite: ${event.chatId}'),
        emit(const FavoriteChatAddedState())
      },
    );
  }
  Future<void> _removeFavoriteChat(RemoveFavoriteChat event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());
    final result = await chatRepository.removeFromFavorite(event.chatId);
    result.fold(
      (failure) => emit(ChatError(failure.toString())),
      (_) => add(const LoadFavoriteChats()),
    );
  }
  
}
