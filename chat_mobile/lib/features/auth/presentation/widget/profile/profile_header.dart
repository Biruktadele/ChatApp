import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constant/api_constant.dart';
import '../../../domain/entities/user.dart';

class ProfileHeader extends StatelessWidget {
  final User? user;
  final VoidCallback onEditImage;
  final double height;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.onEditImage,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize =
        height * 0.4; // Adjust avatar size relative to header height

    return Container(
      height: height,
      width: double.infinity,
      color: Colors.black,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onEditImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Hero(
                  tag: 'profile_avatar',
                  child: CircleAvatar(
                    radius: avatarSize / 2,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage:
                        (user?.avatar != null && user!.avatar!.isNotEmpty)
                        ? CachedNetworkImageProvider(
                            '$cloudinaryUrl${user!.avatar!}',
                          )
                        : null,
                    child: (user?.avatar == null || user!.avatar!.isEmpty)
                        ? Icon(
                            Icons.person,
                            size: avatarSize * 0.6,
                            color: Colors.white54,
                          )
                        : null,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.edit, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.username ?? 'Anonymous',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'No email',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
