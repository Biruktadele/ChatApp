import 'package:flutter/material.dart';

class AnimatedMenuDrawer extends StatelessWidget {
  final AnimationController? controller;
  final String username;
  final String bio;
  final String avatarUrl;
  final VoidCallback onProfileTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const AnimatedMenuDrawer({
    super.key,
    this.controller,
    required this.username,
    required this.bio,
    required this.avatarUrl,
    required this.onProfileTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Profile section
            GestureDetector(
              onTap: onProfileTap,
              child: Hero(
                tag: 'profile-avatar',
                child: CircleAvatar(
                  radius: 44,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(username, style: Theme.of(context).textTheme.titleLarge),
            Text(bio, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            // Menu items
            _AnimatedMenuItem(
              icon: Icons.home,
              text: 'Home',
              onTap: () => Navigator.of(context).pop(),
            ),
            _AnimatedMenuItem(
              icon: Icons.account_circle,
              text: 'Profile',
              onTap: onProfileTap,
            ),
            _AnimatedMenuItem(
              icon: Icons.settings,
              text: 'Settings',
              onTap: onSettingsTap,
            ),
            _AnimatedMenuItem(
              icon: Icons.info_outline,
              text: 'About',
              onTap: () {},
            ),
            const Spacer(),
            // Dark/Light mode toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.light_mode),
                Switch(value: isDarkMode, onChanged: (_) => onThemeToggle()),
                const Icon(Icons.dark_mode),
              ],
            ),
            // Settings and Logout
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: onLogoutTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedMenuItem extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _AnimatedMenuItem({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  State<_AnimatedMenuItem> createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<_AnimatedMenuItem> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _hovered ? Colors.blue.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(widget.icon, color: _hovered ? Colors.blue : null),
          title: Text(
            widget.text,
            style: TextStyle(color: _hovered ? Colors.blue : null),
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
