import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' show read;

import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../domain/entities/chat.dart';
import '../../bloc/bloc/chat_bloc.dart';

class ListUser extends StatefulWidget {
  List<Chat> chats;

  ListUser({super.key, required this.chats});

  @override
  State<ListUser> createState() => _ListUserState();
}

class _ListUserState extends State<ListUser> {
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const GetAllUsers());
  }

  Widget loadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'User List',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is GetAllUsersSuccess) {
            final users = state.users;
            return ListView.builder(
              padding: const EdgeInsets.only(
                top: 100,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                bool isexist = false;
                // debugPrint('User avatar: a${user.avatar}a');
                return Card(
                  elevation: 8,
                  margin: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: Colors.white.withOpacity(0.85),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 18,
                    ),

                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 32,

                            backgroundImage: user.avatar != ""
                                ? NetworkImage(user.avatar!)
                                : const AssetImage('assets/images/man2.jpeg'),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.username ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2575FC),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Online",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A11CB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            elevation: 4,
                          ),
                          
                          onPressed: () {
                            // TODO: Add logic to add user to chatlist
                            for (var chat in widget.chats) {
                              if (chat.user1?.id == user.id || chat.user2?.id == user.id) {
                                isexist = true;
                                break;
                              }
                              
                            }
                            if (isexist) {
                              setState(() {
                                isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User already in chatlist'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            context.read<ChatBloc>().add(CreateChat(user.id!));
                            context.read<ChatBloc>().stream.listen((state) {
                              // Handle chat state changes here if needed
                              if (state is ChatCreated) {
                                setState(() {
                                  isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Added ${user.username} to chatlist',
                                    ),
                                    backgroundColor: const Color(0xFF2575FC),
                                  ),
                                );
                              } else if (state is ChatCreatedError) {
                                setState(() {
                                  isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.message),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else if (state is ChatCreatedLoading) {
                                setState(() {
                                  isLoading = true;
                                });
                              }
                            });
                          },
                          child: isLoading
                              ? loadingIndicator()
                              : const Text('Add to Chatlist'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is GetAllUsersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text('Failed to load users'));
          }
        },
      ),
    );
  }
}
