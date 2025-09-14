import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.name,
    required this.status,
    required this.avatarAsset,
  });

  final String name;
  final String status;
  final String avatarAsset;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.2),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      centerTitle: false,
      leadingWidth: 68,
      leading: Padding(
        padding: const EdgeInsets.only(left: 24.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: AssetImage(avatarAsset),
                radius: 24,
              ),
            ),
            if (status.toLowerCase() == 'online')
              Positioned(
                bottom: 2,
                right: -2,
                child: Container(
                  height: 14,
                  width: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      titleSpacing: 4,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 3),
          Text(
            status,
            style: TextStyle(
              fontSize: 13,
              color: status.toLowerCase() == 'online'
                  ? Colors.green
                  : Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call_outlined, color: Colors.grey),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.videocam_outlined, color: Colors.grey),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
