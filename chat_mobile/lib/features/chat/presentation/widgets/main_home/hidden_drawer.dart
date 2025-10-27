import 'package:flutter/material.dart';

class HiddenDrawer extends StatelessWidget {
  final Function(int) onMenuItemTap;

  const HiddenDrawer({super.key, required this.onMenuItemTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey.shade900,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.grey.shade800),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home_outlined,
            text: 'Home',
            onTap: () {
              onMenuItemTap(0);
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.person_outline,
            text: 'Profile',
            onTap: () {
              onMenuItemTap(1);
              Navigator.pop(context);
            },
          ),
          Divider(color: Colors.grey.shade800),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Logout',
            onTap: () {
              // Handle logout
              
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
      splashColor: Colors.grey.shade800,
    );
  }
}
