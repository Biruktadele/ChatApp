import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/chatwidget/chat_app_bar.dart';
import '../widgets/chatwidget/received_message_bubble.dart';
import '../widgets/chatwidget/sent_message_bubble.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../data/datasources/socketio/socket_io_chat_socket_service.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../bloc/bloc/chat_bloc.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;
  final String username;

  const ChatPage({super.key, required this.chat, required this.username});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  List<Message> messages = [];
  bool typestates = false;
  late final int chatId = widget.chat.id ?? 0;
  int userId = 0;

  final List<String> _aiSuggestions = [
    'Sure, that works',
    "I'll check now",
    "Let's do it later",
  ];
  final TextEditingController _inputController = TextEditingController();

  final ScrollController _scrollController =
      ScrollController(); // Step 1: Add ScrollController

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    debugPrint('username in initState: ${widget.username}');

    final int userId = widget.username == widget.chat.user1?.username
        ? widget.chat.user1?.id ?? 0
        : widget.chat.user2?.id ?? 0;
    this.userId = userId;
    debugPrint('Chat ID: $chatId, User ID: $userId');
    debugPrint('Joining room for chat ID: $chatId and user ID: $userId');
    context.read<ChatBloc>().add(LoadMessages(chatId));
    context.read<ChatBloc>().add(JoinRoomEvent(chatId, userId));

    context.read<ChatBloc>().stream.listen((state) {
      if (state is MessagesLoaded) {
        setState(() {
          messages = state.messages;
        });
        // _scrollToFirstUnread();
      } else if (state is NewMessageReceivedState) {
        setState(() {
          messages.add(state.message);
          _scrollToBottom();
        });
        context.read<ChatBloc>().add(LoadMessages(chatId));

        // _scrollToFirstUnread();
        // context.read<ChatBloc>().add(LoadMessages(chatId));
      } else if (state is SocketJoinedRoomState) {
        // debugPrint('/n/n/n\n\nJoined room successfully. {${widget.chat.user1?.id}, $chatId}\n\n/n/n');
      } else if (state is SocketJoinedErrorState) {
        debugPrint('Socket join room error: ${state.message}');
      } else if (state is MessageSentSuccessState) {
        // context.read<ChatBloc>().add(LoadMessages(chatId));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
        debugPrint('Message sent successfully');
      } else if (state is ChatError) {
        debugPrint('Message sent error: ${state.message}');
      } else if (state is NewTypingState) {
        setState(() {
          typestates = state.typing;
        });
        debugPrint('🥇🥇🥇🥇🥇New typing state: ${state.typing}🥇🥇🥇🥇🥇');
      } else if (state is NewReadReceiptState) {
        // index = messages.indexOf(state.message);
        int index = messages.indexWhere(
          (message) => message.id == state.readReceipts,
        );
        if (index != -1) {
          setState(() {
            messages[index].isRead = true;
          });
        }
      } else if (state is NewSuggestionsState) {
        setState(() {
          _aiSuggestions.clear();
          _aiSuggestions.add(state.suggestions.suggestion1);
          _aiSuggestions.add(state.suggestions.suggestion2);
          _aiSuggestions.add(state.suggestions.suggestion3);
        });
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent - 100,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onSuggestionTap(String text) {
    _inputController.text = text;
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: _inputController.text.length),
    );
  }

  void _sendCurrentMessage() {
    final txt = _inputController.text.trim();
    if (txt.isEmpty) return;
    try {
      context.read<ChatBloc>().add(SendMessageEvent(txt));
      _inputController.clear();
    } catch (e) {
      debugPrint('Send event failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name =
        (widget.username == widget.chat.user1?.username
            ? widget.chat.user2?.username
            : widget.chat.user1?.username) ??
        '';

    return Scaffold(
      appBar: ChatAppBar(
        name: name == widget.username ? 'Saved Messages' : name,
        status: 'online',
        avatarAsset: 'assets/images/man2.jpeg',
        typing_status: typestates,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is NewTypingEvent) {
                  return CircularProgressIndicator();
                } else {
                  // removed unused lastMonth variable
                }
                return ListView.builder(
                  controller:
                      _scrollController, // Step 2: Attach ScrollController
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Message message = messages[index];
                    final month = DateFormat(
                      'MMMM yyyy',
                    ).format(message.createdAt ?? DateTime.now());
                    final bool isSentByUser = message.sender?.id == userId;

                    // Use a static variable to track lastMonth for this build
                    bool showMonthSeparator = false;
                    if (index == 0 ||
                        DateFormat('MMMM yyyy').format(
                              messages[index - 1].createdAt ?? DateTime.now(),
                            ) !=
                            month) {
                      showMonthSeparator = true;
                    }

                    return Column(
                      children: [
                        if (showMonthSeparator)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  month,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        isSentByUser
                            ? SentMessageBubble(
                                text: message.content ?? ' ',
                                time: DateFormat(
                                  'HH:mm',
                                ).format(message.createdAt ?? DateTime.now()),
                                read: message.isRead ?? false,
                              )
                            : VisibilityDetector(
                                key: Key('message-${message.id}'),
                                onVisibilityChanged: (VisibilityInfo info) {
                                  final visiblePercentage =
                                      (info.visibleFraction * 100).round();
                                  if (message.isRead == false &&
                                      visiblePercentage > 50) {
                                    context.read<ChatBloc>().add(
                                      MarkMessageAsReadEvent(
                                        widget.chat.id ?? 0,
                                        message.id ?? 0,
                                      ),
                                    );
                                  }
                                },
                                child: ReceivedMessageBubble(
                                  text: message.content ?? ' ',
                                  time: DateFormat(
                                    'HH:mm',
                                  ).format(message.createdAt ?? DateTime.now()),
                                ),
                              ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          // NEW: Suggestions ABOVE input bar
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_aiSuggestions.isNotEmpty)
                    AISuggestionsBar(
                      suggestions: _aiSuggestions,
                      onTap: _onSuggestionTap,
                    ),
                  const SizedBox(height: 4),
                  _ModernInputBar(
                    controller: _inputController,
                    onSend: _sendCurrentMessage,
                    onCamera: () => debugPrint('Camera tapped'),
                    onMic: () => debugPrint('Mic tapped'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// NEW modern input bar
class _ModernInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onCamera;
  final VoidCallback onMic;
  const _ModernInputBar({
    required this.controller,
    required this.onSend,
    required this.onCamera,
    required this.onMic,
  });
  @override
  State<_ModernInputBar> createState() => _ModernInputBarState();
}

class _ModernInputBarState extends State<_ModernInputBar> {
  bool _sending = false;
  @override
  Widget build(BuildContext context) {
    final canSend = widget.controller.text.trim().isNotEmpty && !_sending;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              minLines: 1,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Message',
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          Row(
            children: [
              _circleIcon(
                icon: Icons.camera_alt_outlined,
                tooltip: 'Camera',
                onTap: widget.onCamera,
              ),
              const SizedBox(width: 6),
              _circleIcon(
                icon: Icons.mic_none_rounded,
                tooltip: 'Voice',
                onTap: widget.onMic,
              ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: canSend ? _handleSend : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: canSend ? const Color(0xFF4C6EF5) : Colors.grey.shade300,
                shape: BoxShape.circle,
                boxShadow: canSend
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4C6EF5).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSend() async {
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 80));
    widget.onSend();
    setState(() => _sending = false);
  }

  Widget _circleIcon({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.grey.shade200,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 20, color: Colors.grey.shade700),
        ),
      ),
    );
  }
}

// NEW AI Suggestions bar (positioned above input)
class AISuggestionsBar extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String) onTap;
  const AISuggestionsBar({
    super.key,
    required this.suggestions,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final items = suggestions.take(3).map(_normalize).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final s in items)
                  _SuggestionChip(text: s, onTap: () => onTap(s)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _normalize(String text) =>
      text.trim().split(RegExp(r'\s+')).take(5).join(' ');
}

class _SuggestionChip extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const _SuggestionChip({required this.text, required this.onTap});
  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xFFF7F5F1);
    return AnimatedScale(
      scale: _pressed ? 0.94 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: baseColor,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: Colors.black.withOpacity(0.04)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: widget.onTap,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                widget.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  color: const Color(0xFF2F2F2F),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
