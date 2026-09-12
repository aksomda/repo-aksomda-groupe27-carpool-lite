import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetMessages {
  final ChatRepository repository;

  GetMessages(this.repository);

  Stream<List<Message>> call({
    required String currentUserId,
    required String contactId,
  }) {
    return repository.getMessagesStream(
      currentUserId: currentUserId,
      contactId: contactId,
    );
  }
}