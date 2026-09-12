import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/chat/domain/entities/message.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/chat/domain/repositories/chat_repository.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/chat/domain/usecases/get_messages.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repository;
  late GetMessages useCase;

  setUp(() {
    repository = MockChatRepository();
    useCase = GetMessages(repository);
  });

  group('GetMessages', () {
    test(
      'doit récupérer le stream des messages',
          () async {
        final messages = [
          Message(
            id: '1',
            senderId: 'user1',
            receiverId: 'user2',
            text: 'Bonjour',
            timestamp: DateTime(2026, 1, 1),
            isRead: true,
          ),
        ];

        final controller =
        StreamController<List<Message>>();

        when(
              () => repository.getMessagesStream(
            currentUserId: 'user1',
            contactId: 'user2',
          ),
        ).thenAnswer(
              (_) => controller.stream,
        );

        final stream = useCase(
          currentUserId: 'user1',
          contactId: 'user2',
        );

        expectLater(
          stream,
          emits(messages),
        );

        controller.add(messages);

        await Future<void>.delayed(
          const Duration(milliseconds: 10),
        );

        await controller.close();

        verify(
              () => repository.getMessagesStream(
            currentUserId: 'user1',
            contactId: 'user2',
          ),
        ).called(1);
      },
    );
  });
}