import '../entities/message.dart';

abstract class ChatRepository {
  /// Messages d'une conversation entre deux utilisateurs
  Stream<List<Message>> getMessagesStream({
    required String currentUserId,
    required String contactId,
  });

  /// Tous les messages concernant un utilisateur
  Stream<List<Message>> getUserMessages(
      String currentUserId,
      );

  /// Envoyer un message
  Future<void> sendMessage({
    required String text,
    required String senderId,
    required String receiverId,
  });

  /// Marquer un message comme lu
  Future<void> markMessageAsRead(
      String messageId,
      );

  /// Marquer toute une conversation comme lue
  Future<void> markConversationAsRead({
    required String currentUserId,
    required String contactId,
  });
}