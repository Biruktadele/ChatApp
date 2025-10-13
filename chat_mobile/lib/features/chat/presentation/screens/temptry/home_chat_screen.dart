// import 'dart:math';

// import 'package:curved_navigation_bar/curved_navigation_bar.dart';

// import '../widgets/home_wdget/faveriet_card.dart';
// import '../widgets/home_wdget/profile_show.dart';
// import '../widgets/home_wdget/serch_bar.dart';
// import '../widgets/home_wdget/user_chat.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../../core/constant/api_constatn.dart';
// import '../../data/datasources/socketio/chat_socket_service.dart';
// import '../../data/datasources/socketio/socket_io_chat_socket_service.dart';
// import '../../domain/entities/chat.dart';
// import '../bloc/bloc/chat_bloc.dart';
// import '../widgets/home_wdget/List_user.dart';
// import 'chat_page.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import '../bloc/bloc/chat_bloc.dart';

// class HomePage extends StatefulWidget {
//   final String username;
//   final String token;
//   // final int userId;
//   const HomePage({super.key, required this.username, required this.token});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   List<Chat> chats = [];
//   bool loading = true;
//   bool error = false;

//   // late SocketIoChatSocketService _socketService;

//   @override
//   void initState() {
//     super.initState();
//     // _socketService = SocketIoChatSocketService();

//     context.read<ChatBloc>().add(
//       ConnectSocketIoEvent(token: widget.token, baseUrl: socketUrl),
//     );

//     context.read<ChatBloc>().add(const LoadChats());
//     context.read<ChatBloc>().stream.listen((state) {
//       if (state is SocketConnectingErrorState) {
//         debugPrint('Socket connection error: ${state.message}');
//       }
//       if (state is SocketConnectedState) {
//         debugPrint('Socket connected successfully.');
//       }
//       if (state is ChatLoaded) {
//         debugPrint('✨✨✨Chats loaded successfully.');
//         debugPrint('Loaded chats: ${state.chats}');
//         setState(() {
//           loading = false;
//           chats = state.chats;
//         });
//       } else if (state is ChatLoading) {
//         setState(() {
//           loading = true;
//         });
//       } else if (state is ChatError) {
//         setState(() {
//           loading = false;
//           error = true;
//         });
//       } else if (state is ChatCreated) {
//         debugPrint('New chat created with ID: ${state.chat.id}');
//         setState(() {
//           chats.add(state.chat);
//         });
//       } else if (state is SocketJoinedErrorState) {
//         debugPrint('\n\n Socket joing room error ${state.message}');
//       } else if (state is SocketJoinedRoomState) {
//         debugPrint('\n\n\n conecting succsesfuly\n\n\n');
//       }
//       else if (state is MakeMessageReadState ) {
//           // debugPrint('Message marked as read:🌟 🌟 🌟 🌟 🌟 ');
          
//           int index = chats.indexWhere((chat) => chat.id == state.chatId);
//           if (index != -1) {
//             setState(() {
//               chats[index].unreadCount = max ( 0 , (chats[index].unreadCount ?? 0) - 1);
//             });
//           }   
        
//       }
//       else if (state is StopTypingState){
//         debugPrint('Stop Typing :⚜️⚜️⚜️⚜️⚜️ ');
//       }
//       else if (state is StartTypingState){
//         debugPrint('Start Typing :🌟 🌟 🌟 🌟 🌟 ');
//       }
//       else if(state is NewTypingState){
//         debugPrint('New Typing :💯💯💯💯🥇🥇🥇🥇🥇 ');
//       }
      
//       else if(state is NewMessageReceivedState){
//         int index = chats.indexWhere((chat) => chat.id == state.message.chat?.id);
//           if (index != -1) {
//             setState(() {
//               if (state.message.sender?.username != widget.username) {
//                   chats[index].unreadCount = max ( 0 , (chats[index].unreadCount ?? 0) + 1);
//                 // If the new message is sent by the current user, do not increment unread count
//                 return;
//               }
//               chats[index].lastMessage = state.message.content;
//               chats[index].lastMessageTime = state.message.createdAt;
//             });
//           }   
//       }
//     });
    
  
//   }

//   @override
//   Widget build(BuildContext context) {
//     // context.read<ChatBloc>().add(const LoadChats());

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: <Widget>[
//           SliverPersistentHeader(
//             pinned: true,
//             delegate: _SliverAppBarDelegate(
//               minHeight: 100.0,
//               maxHeight: 100.0,
//               child: Container(
//                 color: Theme.of(context).scaffoldBackgroundColor,
//                 child: ProfileShow(username: widget.username),
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.only(left: 32, top: 16, bottom: 16),
//               child: Row(
//                 children: [
//                   const SearchBarr(),
//                   Container(
//                     margin: const EdgeInsets.only(left: 16),

//                     decoration: BoxDecoration(
//                       color: Colors.blue,
//                       borderRadius: BorderRadius.circular(12),
//                     ),

//                     child: IconButton(
//                       icon: const Icon(
//                         Icons.add,
//                         color: Colors.white,
//                         size: 30,
//                       ),
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ListUser(chats: chats),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SliverPersistentHeader(
//             pinned: true,
//             delegate: _SliverAppBarDelegate(
//               minHeight: 180.0,
//               maxHeight: 180.0,
//               child: Container(
//                 color: Theme.of(context).scaffoldBackgroundColor,
//                 child: SizedBox(
//                   height: 160,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: 10,
//                     itemBuilder: (context, index) {
//                       return const Padding(
//                         padding: EdgeInsets.only(left: 32, top: 16),
//                         child: FaverietCard(),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           if (!loading && !error)
//             SliverList(
//               delegate: SliverChildBuilderDelegate((
//                 BuildContext context,
//                 int index,
//               ) {
//                 final chat = chats[index];
//                 return TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             ChatPage(chat: chat , username: widget.username),
//                       ),
//                     );
//                   },
//                   child: UserChat(chat: chat, username: widget.username),
//                 );
//               }, childCount: chats.length),
//             ),
//           if (loading)
//             const SliverFillRemaining(
//               child: Center(child: CircularProgressIndicator()),
//             ),
//           if (error)
//             const SliverFillRemaining(
//               child: Center(child: Text('Failed to load chats')),
//             ),
//         ],
//       ),
   
//     bottomNavigationBar: CurvedNavigationBar(
//     backgroundColor: Colors.blueAccent,
//     items: <Widget>[
//       Icon(Icons.chat, size: 30),
//       Icon(Icons.favorite_rounded, size: 30),
//       Icon(Icons.person, size: 30),
//       Icon(Icons.settings, size: 30),
//     ],
//     onTap: (index) {
//       //Handle button tap
//     },
//   ),
//     );
//   }
// }

// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   _SliverAppBarDelegate({
//     required this.minHeight,
//     required this.maxHeight,
//     required this.child,
//   });

//   final double minHeight;
//   final double maxHeight;
//   final Widget child;

//   @override
//   double get minExtent => minHeight;

//   @override
//   double get maxExtent => maxHeight;

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return SizedBox.expand(child: child);
//   }

//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return maxHeight != oldDelegate.maxHeight ||
//         minHeight != oldDelegate.minHeight ||
//         child != oldDelegate.child;
//   }
// }
