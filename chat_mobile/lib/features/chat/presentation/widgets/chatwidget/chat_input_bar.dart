import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../bloc/bloc/chat_bloc.dart';

class ChatInputBar extends StatefulWidget {
  final int chatId;
  const ChatInputBar({super.key, required this.chatId});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {

  late FocusNode _inputFocusNode;
  int userId = 0;
void initState() {
  super.initState();
  _inputFocusNode = FocusNode();
  _inputFocusNode.addListener(_onInputFocusChange);
  const storage = FlutterSecureStorage();
  storage.read(key: 'userId').then((value) {
    setState(() {
      userId = int.parse(value ?? '0');
    });
  });
  // ...existing code...
}
  final TextEditingController _controller = TextEditingController();

  void _onInputFocusChange() {
  if (_inputFocusNode.hasFocus) {
    // Text box is focused (user tapped in)
    debugPrint('✅✅Text input focused!');
    // Emit start typing event here
    context.read<ChatBloc>().add(StartTypingEvent(widget.chatId , userId));
  } else {
    // Text box is unfocused (user tapped out)
    debugPrint('✅✅Text input unfocused!');
    // Emit stop typing event here
    context.read<ChatBloc>().add(StopTypingEvent(widget.chatId, userId));
  }
}
@override
void dispose() {
  _inputFocusNode.removeListener(_onInputFocusChange);
  _inputFocusNode.dispose();
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                focusNode: _inputFocusNode,
                controller: _controller,
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      
                      final text = _controller.text.trim();
                      if (text.isNotEmpty) {
                        context.read<ChatBloc>().add(
                          SendMessageEvent(text),
                        );
                        _controller.clear(); // Clear input after sending
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.blue,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: () {
                      

                    },
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.green,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.mic, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
