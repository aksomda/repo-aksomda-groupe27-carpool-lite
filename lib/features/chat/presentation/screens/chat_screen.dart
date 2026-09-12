import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String currentUserId;
  final String contactId;

  const ChatDetailScreen({
    super.key,
    required this.currentUserId,
    required this.contactId,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() =>
      _ChatDetailScreenState();
}

class _ChatDetailScreenState
    extends ConsumerState<ChatDetailScreen> {
  // ============================================================
  // CONTROLLER
  // ============================================================

  final TextEditingController _controller =
  TextEditingController();

  // ============================================================
  // ENVOYER UN MESSAGE
  // ============================================================

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      return;
    }

    try {
      await ref.read(sendMessageProvider)(
        text,
        widget.currentUserId,
        widget.contactId,
      );

      // Vide le champ après l'envoi
      _controller.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur : $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // INITIALISATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(markMessagesAsReadProvider)(
        currentUserId: widget.currentUserId,
        contactId: widget.contactId,
      );
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      messagesProvider(
        ChatParams(
          currentUserId: widget.currentUserId,
          contactId: widget.contactId,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF123B7A),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(
                'assets/profile.png',
              ),
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contactId,
                  style: const TextStyle(
                    color: Color(0xFF123B7A),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const Text(
                  'En ligne',
                  style: TextStyle(
                    color: Color(0xFF00B894),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF123B7A),
            ),
            onPressed: () {},
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Column(
        children: [
          // ======================================================
          // MESSAGES
          // ======================================================

          Expanded(
            child: messagesAsync.when(
              // --------------------------------------------------
              // LOADING
              // --------------------------------------------------

              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },

              // --------------------------------------------------
              // ERROR
              // --------------------------------------------------

              error: (error, _) {
                return Center(
                  child: Text(
                    'Erreur : $error',
                  ),
                );
              },

              // --------------------------------------------------
              // DATA
              // --------------------------------------------------

              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun message',
                    ),
                  );
                }

                return ListView.builder(

                  reverse: false,

                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),

                  itemCount: messages.length,

                  itemBuilder: (context, index) {
                    final message = messages[index];

                    return MessageBubble(
                      message: message,
                      isMe:
                      message.senderId ==
                          widget.currentUserId,
                    );
                  },
                );
              },
            ),
          ),

          // ======================================================
          // BARRE D'ENVOI
          // ======================================================

          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                10,
              ),

              color: Colors.white,

              child: Row(
                children: [
                  // ------------------------------------------------
                  // CHAMP TEXTE
                  // ------------------------------------------------

                  Expanded(
                    child: TextField(
                      controller: _controller,

                      textInputAction:
                      TextInputAction.send,

                      onSubmitted: (_) {
                        _sendMessage();
                      },

                      decoration: InputDecoration(
                        hintText:
                        'Écrire un message...',

                        filled: true,

                        fillColor:
                        const Color(0xFFF0F6FF),

                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(25),

                          borderSide:
                          BorderSide.none,
                        ),

                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ------------------------------------------------
                  // BOUTON ENVOYER
                  // ------------------------------------------------

                  Material(
                    color: const Color(0xFF1468F5),

                    shape: const CircleBorder(),

                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),

                      onPressed: _sendMessage,
                    ),
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