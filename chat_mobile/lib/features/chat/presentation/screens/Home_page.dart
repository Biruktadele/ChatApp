// ignore: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/page/Profile_screen.dart';
import '../../domain/entities/chat.dart';
import '../bloc/bloc/chat_bloc.dart';
import '../widgets/main_home/animated_app_bar.dart';
import 'page/feverite.dart';
import 'page/home_chat_page.dart';
import '../widgets/main_home/hidden_drawer.dart';
import 'page/settings_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String token;

  HomePage({super.key, required this.username, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isDarkMode = false;
  late AnimationController _drawerController;

  void _onMenuItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  void _onLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement actual logout logic
              Navigator.pop(context); // Close dialog
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      context.read<ChatBloc>().add(LoadChats());
    });
    List<Widget> pages = [
      HomeChatPage(username: widget.username),
      ProfileScreen(onBack: () {}),
      SettingsPage(),
    ];

    return Scaffold(
      drawer: HiddenDrawer(
        onMenuItemTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
      appBar: AnimatedAppBar(
        title: _selectedIndex == 0
            ? 'Home'
            : _selectedIndex == 1
            ? 'Profile'
            : _selectedIndex == 2
            ? 'Settings'
            : 'Settings',
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _onLogout),
        ],
        animation: AlwaysStoppedAnimation(1.0),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: pages[_selectedIndex],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }
}
