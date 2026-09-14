import '../repositories/chat_repository.dart';

class MarkMessagesAsRead {
  final ChatRepository repository;

  MarkMessagesAsRead(this.repository);

  Future<void> call({
    required String currentUserId,
    required String contactId,
  }) {
    return repository.markConversationAsRead(
      currentUserId: currentUserId,
      contactId: contactId,
    );
  }
}