import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetUserMessages {
  final ChatRepository repository;

  GetUserMessages(this.repository);

  Stream<List<Message>> call(
      String currentUserId,
      ) {
    return repository.getUserMessages(
      currentUserId,
    );
  }
}