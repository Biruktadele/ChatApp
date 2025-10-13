import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../../../domain/entities/chat.dart';
import '../../bloc/bloc/chat_bloc.dart';
import '../../widgets/home_wdget/faveriet_card.dart';
import '../../widgets/home_wdget/user_chat.dart';
import '../chat_page.dart';
import 'feverite.dart';

class HomeChatPage extends StatelessWidget {
  final String username;
  HomeChatPage({super.key, required this.username});
  List<Chat> chats = [];
  List<Chat> favoriteChats = [];
  Set<int> favoriteChatIds = {}; // Example favorite chat IDs

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      context.read<ChatBloc>().add(LoadChats());
      context.read<ChatBloc>().add(LoadFavoriteChats());
    });
    return Container(
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoaded) {
            chats = state.chats;
            debugPrint('Loaded chats: ${state.chats}');
          } 
          if (state is FavoriteChatsLoaded) {
            favoriteChats = state.favoriteChats;
            favoriteChatIds =
                favoriteChats.map((chat) => chat.id ?? 0).toSet();
            debugPrint('Loaded favorite chats: ${state.favoriteChats}');
          }
          else if (state is ChatError) {}
          return Column(
            children: [
              if (favoriteChats.isNotEmpty) ...[
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: favoriteChats.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  itemBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: FaverietCard(),
                    );
                  },
                ),
              ),],

              Expanded(
                child: LiquidPullToRefresh(
                  onRefresh: () async {
                    context.read<ChatBloc>().add(const LoadChats());
                  },
                  child: ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      final user = chat.user1?.username != username
                          ? chat.user2
                          : chat.user1;
                      return Slidable(
                        startActionPane: ActionPane(
                          motion: const StretchMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                // Handle delete action
                              },
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                context.read<ChatBloc>().add(AddFavoriteChat(chat.id ?? 3));
                              },
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              icon: Icons.favorite,
                              label: 'Favorite',
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatPage(chat: chat, username: username),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            width: 360,

                            child: UserChat(
                              chat: chat,
                              username: user?.username,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
