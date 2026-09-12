import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';

import '../datasources/firebase_chat_datasource.dart';
import '../model/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseChatDataSource dataSource;

  ChatRepositoryImpl({
    required this.dataSource,
  });

  // ============================================================
  // RÉCUPÉRER LES MESSAGES D'UNE CONVERSATION
  // ============================================================

  @override
  Stream<List<Message>> getMessagesStream({
    required String currentUserId,
    required String contactId,
  }) {
    return dataSource
        .getMessagesStream(
      currentUserId: currentUserId,
      contactId: contactId,
    )
        .map(
          (messages) => messages
          .map(
            (message) => message.toEntity(),
      )
          .toList(),
    );
  }

  // ============================================================
  // RÉCUPÉRER TOUS LES MESSAGES DE L'UTILISATEUR
  // ============================================================

  @override
  Stream<List<Message>> getUserMessages(
      String currentUserId,
      ) {
    return dataSource
        .getUserMessages(currentUserId)
        .map(
          (messages) => messages
          .map(
            (message) => message.toEntity(),
      )
          .toList(),
    );
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

    final message = MessageModel(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      text: cleanText,
      timestamp: DateTime.now(),
      isRead: false,
      type: 'text',
    );

    await dataSource.sendMessage(message);
  }

  // ============================================================
  // MARQUER UNE CONVERSATION COMME LUE
  // ============================================================

  @override
  Future<void> markConversationAsRead({
    required String currentUserId,
    required String contactId,
  }) {
    return dataSource.markConversationAsRead(
      currentUserId: currentUserId,
      contactId: contactId,
    );
  }

  // ============================================================
  // MARQUER UN MESSAGE COMME LU
  // ============================================================

  @override
  Future<void> markMessageAsRead(
      String messageId,
      ) {
    return dataSource.markMessageAsRead(
      messageId,
    );
  }
}