import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_provider.dart';
import '../widgets/conversationcard.dart';
import '../widgets/navbar.dart';
import 'chat_screen.dart';

class ChatListScreen
    extends ConsumerStatefulWidget {

  final AuthProvider authProvider;

  const ChatListScreen({
    super.key,
    required this.authProvider,
  });

  @override
  ConsumerState<ChatListScreen>
  createState() =>
      _ChatListScreenState();
}

class _ChatListScreenState
    extends ConsumerState<ChatListScreen> {

  final TextEditingController
  _searchController =
  TextEditingController();

  String _search = '';


  late final currentUser;

  @override
  void initState() {
    currentUser = widget.authProvider.user;
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getContactId(
      Message message,
      ) {
    return message.senderId ==
        currentUser.uid
        ? message.receiverId
        : message.senderId;
  }

  String _formatDate(
      DateTime date,
      ) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    }

    if (date.day ==
        now.day - 1 &&
        date.month == now.month) {
      return 'Hier';
    }

    const days = [
      'Lun',
      'Mar',
      'Mer',
      'Jeu',
      'Ven',
      'Sam',
      'Dim',
    ];

    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
    ref.watch(
      userMessagesProvider(
        currentUser.uid,
      ),
    );

    return Scaffold(
      backgroundColor:
      const Color(0xFFF8FBFF),

      body: SafeArea(
        child: Column(
          children: [

            // =================================================
            // HEADER
            // =================================================

            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                28,
                15,
                20,
                0,
              ),
              child: Row(
                children: [

                  Image.asset(
                    'assets/images/CarPoolLite_logo_sn.png',
                    width: 155,
                  ),

                  const Spacer(),

                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons
                              .notifications_none_rounded,
                          size: 30,
                          color:
                          Color(0xFF123B7A),
                        ),
                        onPressed: () {},
                      ),

                      Positioned(
                        right: 7,
                        top: 6,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration:
                          const BoxDecoration(
                            color: Colors.red,
                            shape:
                            BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 5),

                  const CircleAvatar(
                    radius: 25,
                    backgroundImage:
                    AssetImage(
                      'assets/profile.png',
                    ),
                  ),

                  const Icon(
                    Icons
                        .keyboard_arrow_down_rounded,
                    color:
                    Color(0xFF123B7A),
                    size: 28,
                  ),
                ],
              ),
            ),

            // =================================================
            // TITRE
            // =================================================

            const Padding(
              padding:
              EdgeInsets.fromLTRB(
                28,
                25,
                28,
                18,
              ),
              child: Align(
                alignment:
                Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      'Messages',
                      style: TextStyle(
                        color:
                        Color(0xFF123B7A),
                        fontSize: 40,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: 2),

                    Text(
                      'Restez en contact avec vos '
                          'covoitureurs et amis !',
                      style: TextStyle(
                        color:
                        Color(0xFF7893BA),
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =================================================
            // RECHERCHE
            // =================================================

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 28,
              ),
              child: TextField(
                controller:
                _searchController,

                onChanged: (value) {
                  setState(() {
                    _search =
                        value.toLowerCase();
                  });
                },

                decoration:
                InputDecoration(
                  hintText:
                  'Rechercher une conversation...',
                  hintStyle:
                  const TextStyle(
                    color:
                    Color(0xFF7893BA),
                    fontSize: 16,
                  ),

                  prefixIcon:
                  const Icon(
                    Icons.search_rounded,
                    size: 31,
                    color:
                    Color(0xFF6085BA),
                  ),

                  filled: true,
                  fillColor:
                  const Color(
                    0xFFEAF4FF,
                  ),

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      30,
                    ),
                    borderSide:
                    BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // CONVERSATIONS
            // =================================================

            Expanded(
              child: messagesAsync.when(

                loading: () =>
                const Center(
                  child:
                  CircularProgressIndicator(),
                ),

                error: (error, _) =>
                    Center(
                      child: Text(
                        'Erreur : $error',
                      ),
                    ),

                data: (messages) {

                  // Dernier message par contact
                  final Map<
                      String,
                      Message> latest = {};

                  for (final message
                  in messages) {
                    final contact =
                    currentUser.uid;

                    final previous =
                    latest[contact];

                    if (previous ==
                        null ||
                        message.timestamp
                            .isAfter(
                          previous.timestamp,
                        )) {
                      latest[contact] =
                          message;
                    }
                  }

                  final conversations =
                  latest.values
                      .where((message) {
                    final contact =
                    currentUser.uid;

                    return contact
                        .toLowerCase()
                        .contains(
                      _search,
                    ) ||
                        message.text
                            .toLowerCase()
                            .contains(
                          _search,
                        );
                  })
                      .toList()
                    ..sort(
                          (a, b) => b.timestamp
                          .compareTo(
                        a.timestamp,
                      ),
                    );

                  if (conversations
                      .isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucune conversation',
                      ),
                    );
                  }

                  return ListView.builder(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 18,
                    ),
                    itemCount:
                    conversations.length,

                    itemBuilder:
                        (context, index) {

                      final message =
                      conversations[
                      index];

                      final contact =
                      _getContactId(
                        message,
                      );

                      final unread =
                          !message.isRead &&
                              message.receiverId ==
                                  currentUser.uid;

                      return ConversationCard(
                        contactId: contact,
                        message: message,
                        unread: unread,
                        date: _formatDate(
                          message.timestamp,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProviderScope(child: ChatDetailScreen(
                                    currentUserId:
                                    currentUser.uid,
                                    contactId:
                                    contact,
                                  ),)
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // =====================================================
      // BOTTOM NAVIGATION
      // =====================================================

      bottomNavigationBar:
      MaBottomNavigationBar(),
    );
  }
}