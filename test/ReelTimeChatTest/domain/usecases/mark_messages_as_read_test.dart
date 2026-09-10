import 'package:repo_aksomda_groupe27_carpool_lite/features/ReelTimeChat/domain/repositories/chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/ReelTimeChat/domain/usecases/mark_messages_as_read.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repository;
  late MarkMessagesAsRead useCase;

  setUp(() {
    repository = MockChatRepository();
    useCase = MarkMessagesAsRead(repository);
  });

  test(
    'doit marquer la conversation comme lue',
        () async {
      when(
            () => repository.markConversationAsRead(
          currentUserId: 'user1',
          contactId: 'user2',
        ),
      ).thenAnswer((_) async {});

      await useCase(
        currentUserId: 'user1',
        contactId: 'user2',
      );

      verify(
            () => repository.markConversationAsRead(
          currentUserId: 'user1',
          contactId: 'user2',
        ),
      ).called(1);
    },
  );
}