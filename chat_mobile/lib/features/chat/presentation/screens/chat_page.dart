import 'package:flutter/material.dart';
import 'package:chat_mobile/features/chat/presentation/widgets/chatwidget/chat_app_bar.dart';
import 'package:chat_mobile/features/chat/presentation/widgets/chatwidget/received_message_bubble.dart';
import 'package:chat_mobile/features/chat/presentation/widgets/chatwidget/sent_message_bubble.dart';
import 'package:chat_mobile/features/chat/presentation/widgets/chatwidget/chat_input_bar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChatAppBar(
        name: 'Biruk Tadele',
        status: 'online',
        avatarAsset: 'assets/images/man2.jpeg',
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              children: const [
                ReceivedMessageBubble(
                  text:
                      'Hey! Are we still on for today? I found a great place we can check out.',
                  time: '10:10 AM',
                ),
                SentMessageBubble(
                  text: "Absolutely! I'm excited. What time works for you?",
                  time: '10:12 AM',
                  read: true,
                ),
                ReceivedMessageBubble(
                  text:
                      'Let\'s meet at 3 PM near the main square. Does that work? ',
                  time: '10:14 AM',
                ),
                SentMessageBubble(
                  text: 'Perfect! See you then 👍',
                  time: '10:15 AM',
                  read: false,
                ),
              ],
            ),
          ),
          const ChatInputBar(),
        ],
      ),
    );
  }
}
