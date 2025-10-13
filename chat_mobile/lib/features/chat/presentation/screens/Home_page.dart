// ignore: file_names


import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat.dart';
import '../bloc/bloc/chat_bloc.dart';
import 'page/feverite.dart';
import 'page/home_chat_page.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/bloc/chat_bloc.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String token;

  HomePage({super.key, required this.username, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Chat> chats = [];

  int pindex = 0;

  // late SocketIoChatSocketService _socketService;
  @override 
  Widget build(BuildContext context) {
    Future.microtask(() {
      context.read<ChatBloc>().add(LoadChats());
    });
    List<Widget> pages = [HomeChatPage(username: widget.username) , FeveritePage() ];


    return Scaffold(

      
      appBar: AppBar(
        title: const Text('Home Page', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: pages[pindex],

      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.grey.shade800,
        buttonBackgroundColor: Colors.grey.shade800,
        height: 50,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.favorite, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          // Handle button tap if needed
          setState(() {
            pindex = index;
          });
        },
      ),
    );
  }
}
