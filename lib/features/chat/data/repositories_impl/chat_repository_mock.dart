import 'dart:async';

import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryMock implements ChatRepository {
  // ============================================================
  // CONSTANTE
  // ============================================================

  static const String currentUserId = 'currentUser';

  // ============================================================
  // DONNÉES MOCK
  // ============================================================

  final List<Message> _messages = [
    // ------------------------------------------------------------
    // Thomas N. <-> currentUser
    // ------------------------------------------------------------

    Message(
      id: '1',
      senderId: 'currentUser',
      receiverId: 'thomas',
      text:
      'Salut ! Est-ce que tu es toujours partant pour le trajet demain ?',
      timestamp: DateTime.now().subtract(
        const Duration(minutes: 16),
      ),
      isRead: true,
    ),

    Message(
      id: '2',
      senderId: 'thomas',
      receiverId: 'currentUser',
      text: 'Oui, je serai au point de rendez-vous à 7h30.',
      timestamp: DateTime.now().subtract(
        const Duration(minutes: 10),
      ),
      isRead: true,
    ),

    Message(
      id: '3',
      senderId: 'currentUser',
      receiverId: 'thomas',
      text: 'Parfait, à demain !',
      timestamp: DateTime.now().subtract(
        const Duration(minutes: 5),
      ),
      isRead: true,
    ),

    // ------------------------------------------------------------
    // Sarah M. <-> currentUser
    // ------------------------------------------------------------

    Message(
      id: '4',
      senderId: 'sarah',
      receiverId: 'currentUser',
      text:
      'D’accord ! Je serai au point de rendez-vous à 7h30. À demain ! 👋',
      timestamp: DateTime.now().subtract(
        const Duration(hours: 2),
      ),
      isRead: true,
    ),

    // ------------------------------------------------------------
    // Kevin L. <-> currentUser
    // ------------------------------------------------------------

    Message(
      id: '5',
      senderId: 'currentUser',
      receiverId: 'kevin',
      text: 'Oui, je peux te confirmer la place dans la voiture.',
      timestamp: DateTime.now().subtract(
        const Duration(days: 1, hours: 1),
      ),
      isRead: true,
    ),

    Message(
      id: '6',
      senderId: 'kevin',
      receiverId: 'currentUser',
      text: 'Tu peux me confirmer la place dans la voiture ?',
      timestamp: DateTime.now().subtract(
        const Duration(days: 1),
      ),
      isRead: true,
    ),

    // ------------------------------------------------------------
    // Diane K. <-> currentUser
    // ------------------------------------------------------------

    Message(
      id: '7',
      senderId: 'diane',
      receiverId: 'currentUser',
      text: 'Oui bien sûr ! On se voit à 8h au campus ?',
      timestamp: DateTime.now().subtract(
        const Duration(days: 2),
      ),
      isRead: true,
    ),

    // ------------------------------------------------------------
    // Alex D. <-> currentUser
    // ------------------------------------------------------------

    Message(
      id: '9',
      senderId: 'alex',
      receiverId: 'currentUser',
      text: 'Merci beaucoup ! 🙏',
      timestamp: DateTime.now().subtract(
        const Duration(days: 4),
      ),
      isRead: true,
    ),
  ];

  // ============================================================
  // STREAM GLOBAL
  // ============================================================

  final StreamController<void> _messageController =
  StreamController<void>.broadcast();

  // ============================================================
  // RÉCUPÉRER UNE CONVERSATION
  // ============================================================

  @override
  Stream<List<Message>> getMessagesStream({
    required String currentUserId,
    required String contactId,
  }) async* {
    // Première émission
    yield _getConversation(
      currentUserId,
      contactId,
    );

    // Nouvelles émissions à chaque modification
    await for (final _ in _messageController.stream) {
      yield _getConversation(
        currentUserId,
        contactId,
      );
    }
  }

  // ============================================================
  // FILTRER UNE CONVERSATION
  // ============================================================

  List<Message> _getConversation(
      String currentUserId,
      String contactId,
      ) {
    final messages = _messages.where((message) {
      final sentByMe =
          message.senderId == currentUserId &&
              message.receiverId == contactId;

      final receivedFromContact =
          message.senderId == contactId &&
              message.receiverId == currentUserId;

      return sentByMe || receivedFromContact;
    }).toList();

    // Plus récent → plus ancien
    messages.sort(
          (a, b) => b.timestamp.compareTo(a.timestamp),
    );

    return messages;
  }

  // ============================================================
  // RÉCUPÉRER TOUS LES MESSAGES DE L'UTILISATEUR
  // ============================================================

  @override
  Stream<List<Message>> getUserMessages(
      String currentUserId,
      ) async* {
    // Première émission
    yield _getUserMessages(currentUserId);

    // Mise à jour automatique
    await for (final _ in _messageController.stream) {
      yield _getUserMessages(currentUserId);
    }
  }

  // ============================================================
  // FILTRER LES MESSAGES DE L'UTILISATEUR
  // ============================================================

  List<Message> _getUserMessages(
      String currentUserId,
      ) {
    final messages = _messages.where((message) {
      return message.senderId == currentUserId ||
          message.receiverId == currentUserId;
    }).toList();

    // Plus récent → plus ancien
    messages.sort(
          (a, b) => b.timestamp.compareTo(a.timestamp),
    );

    return messages;
  }

  // ============================================================
  // ENVOYER UN MESSAGE
  // ============================================================

  @override
  Future<void> sendMessage({
    required String text,
    required String senderId,
    required String receiverId,
  }) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      return;
    }

    final message = Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      senderId: senderId,
      receiverId: receiverId,
      text: cleanText,
      timestamp: DateTime.now(),

      // Un message envoyé par l'utilisateur est considéré
      // comme lu dans notre Mock.
      isRead: true,
    );

    _messages.add(message);

    // Notifie tous les streams
    _messageController.add(null);
  }

  // ============================================================
  // SIMULER LA RÉCEPTION D'UN MESSAGE
  // ============================================================

  Future<void> receiveMessage({
    required String text,
    required String senderId,
    required String receiverId,
  }) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      return;
    }

    final message = Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      senderId: senderId,
      receiverId: receiverId,
      text: cleanText,
      timestamp: DateTime.now(),

      // Message entrant non lu
      isRead: false,
    );

    _messages.add(message);

    // Notifie tous les streams
    _messageController.add(null);
  }

  // ============================================================
  // DERNIER MESSAGE
  // ============================================================

  Message? getLastMessage(
      String currentUserId,
      String contactId,
      ) {
    final messages = _getConversation(
      currentUserId,
      contactId,
    );

    if (messages.isEmpty) {
      return null;
    }

    return messages.first;
  }

  // ============================================================
  // NOMBRE DE MESSAGES NON LUS
  // ============================================================

  int getUnreadCount({
    required String currentUserId,
    required String contactId,
  }) {
    return _messages.where((message) {
      return message.senderId == contactId &&
          message.receiverId == currentUserId &&
          !message.isRead;
    }).length;
  }

  // ============================================================
  // MARQUER UNE CONVERSATION COMME LUE
  // ============================================================

  @override
  Future<void> markConversationAsRead({
    required String currentUserId,
    required String contactId,
  }) async {
    for (int i = 0; i < _messages.length; i++) {
      final message = _messages[i];

      final isReceivedMessage =
          message.senderId == contactId &&
              message.receiverId == currentUserId;

      if (isReceivedMessage && !message.isRead) {
        _messages[i] = Message(
          id: message.id,
          senderId: message.senderId,
          receiverId: message.receiverId,
          text: message.text,
          timestamp: message.timestamp,
          isRead: true,
        );
      }
    }

    // Met à jour l'interface
    _messageController.add(null);
  }

  // ============================================================
  // MARQUER UN MESSAGE PRÉCIS COMME LU
  // ============================================================

  @override
  Future<void> markMessageAsRead(
      String messageId,
      ) async {
    final index = _messages.indexWhere(
          (message) => message.id == messageId,
    );

    if (index == -1) {
      return;
    }

    final message = _messages[index];

    if (message.isRead) {
      return;
    }

    _messages[index] = Message(
      id: message.id,
      senderId: message.senderId,
      receiverId: message.receiverId,
      text: message.text,
      timestamp: message.timestamp,
      isRead: true,
    );

    // Met à jour l'interface
    _messageController.add(null);
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    if (!_messageController.isClosed) {
      _messageController.close();
    }
  }
}