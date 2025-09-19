import 'package:flutter/material.dart';
import 'package:chat_mobile/features/chat/presentation/widgets/chatwidget/chat_app_bar.dart';
import 'package:chat_mobile/features/chat/presentation/widgets/chatwidget/received_message_bubble.dart';
import 'package:chat_mobile/features/chat/presentation/widgets/chatwidget/sent_message_bubble.dart';
import 'package:chat_mobile/features/chat/presentation/widgets/chatwidget/chat_input_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'remote_data_source.dart';
import '../../data/datasources/socketio/socket_io_chat_socket_service.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../bloc/bloc/chat_bloc.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;
  final int? userId;
  ChatPage({super.key, required this.chat , this.userId});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String? username;
  List<Message> messages = [];
  late final int chatId = widget.chat.id ?? 0;
  late SocketIoChatSocketService _socketService;

  @override
  void initState() {
    super.initState();
    secureStorage.read(key: 'username').then((value) {
      setState(() {
        username = value;
      });
    });
  _socketService = SocketIoChatSocketService();
  _socketService.messages.listen((message) {
    context.read<ChatBloc>().add(NewMessageReceivedEvent(message));
  });

    final int userId = username == widget.chat.user1?.username
        ? widget.chat.user1?.id ?? 0
        : widget.chat.user2?.id ?? 0;
    context.read<ChatBloc>().add(LoadMessages(chatId));
    context.read<ChatBloc>().add(JoinRoomEvent(chatId, userId));

    context.read<ChatBloc>().stream.listen((state) {
      if (state is MessagesLoaded) {
        setState(() {
          messages = state.messages;
        });
      }
      else if (state is NewMessageReceivedState) {
        debugPrint('\n\n\n\nNew message received: ${state.message}');
        setState(() {
          messages.add(state.message);
        });
      }
      else if (state is SocketJoinedRoomState) {
        debugPrint('/n/n/n\n\nJoined room successfully. {${widget.userId}, ${chatId}}\n\n/n/n');
      }
      else if(state is SocketJoinedErrorState){
        debugPrint('Socket join room error: ${state.message}');
      }
      else if(state is MessageSentSuccessState){
        debugPrint('Message sent successfully');

      } else if(state is ChatError){
        debugPrint('Message sent error: ${state.message}');
      }
      
   
    });
  }

  @override
  Widget build(BuildContext context) {
    final String name =
        (username == widget.chat.user1?.username
            ? widget.chat.user2?.username
            : widget.chat.user1?.username) ??
        '';

    return Scaffold(
      appBar: ChatAppBar(
        name: name == username ? "Saved Messages" : name,
        status: 'online',
        avatarAsset: 'assets/images/man2.jpeg',
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                
                 
                 
                  return ListView.builder(
                    // reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      // debugPrint('Rendering message: ${message}');
                      final isSentByUser =
                          message.sender?.username == (username ?? '') ;

                      if (isSentByUser) {
                        return SentMessageBubble(
                          text: message.content ?? ' ',
                          time: (message.createdAt ?? '').toString(),
                          read: message.isRead ?? false,
                        );
                      } else {
                        return ReceivedMessageBubble(
                          text: message.content ?? ' ',
                          time: (message.createdAt ?? '').toString(),
                        );
                      }
                    },
                  );
                
              },
            ),
          ),
          ChatInputBar(chatId: widget.chat.id ?? 0),
        ],
      ),
    );
  }
}
