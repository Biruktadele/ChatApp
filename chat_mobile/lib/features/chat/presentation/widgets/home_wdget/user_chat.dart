import 'package:flutter/material.dart';

import '../../../domain/entities/chat.dart';

class UserChat extends StatefulWidget {
  final Chat? chat;
  final String? username;
  const UserChat({super.key , this.chat , this.username});

  @override
  State<UserChat> createState() => _UserChatState();
}

class _UserChatState extends State<UserChat> {
  @override
  Widget build(BuildContext context) {
    final String name = (widget.username == widget.chat?.user1?.username
            ? widget.chat?.user2?.username
            : widget.chat?.user1?.username) ??
        'Unknown';
    return Container(

      
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(
                    widget.chat?.avatar ?? 'assets/images/man2.jpeg'),
                  ), // Example image
            
                Positioned(
                  top: -5,
                  left: -5,
                  child: (widget.chat?.unreadCount != null && widget.chat!.unreadCount! > 0)
                      ? Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 82, 70, 70),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '+${widget.chat?.unreadCount?.toString() ?? '0'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name == widget.username ? 'Saved Messages' : name, // Example name
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                      widget.chat?.lastMessage ?? 'No message', // Example last message
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${widget.chat?.lastMessageTime?.hour ?? '00'}:${widget.chat?.lastMessageTime?.minute ?? '00'}', // Example date
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
