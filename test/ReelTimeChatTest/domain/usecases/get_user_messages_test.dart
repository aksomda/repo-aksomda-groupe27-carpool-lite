import 'dart:async';

import 'package:repo_aksomda_groupe27_carpool_lite/features/ReelTimeChat/domain/entities/message.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/ReelTimeChat/domain/repositories/chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/ReelTimeChat/domain/usecases/get_user_messages.dart';


class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repository;
  late GetUserMessages useCase;

  setUp(() {
    repository = MockChatRepository();
    useCase = GetUserMessages(repository);
  });

  test(
    'doit récupérer les messages de l utilisateur',
        () async {
      final messages = [
        Message(
          id: '1',
          senderId: 'user1',
          receiverId: 'user2',
          text: 'Salut',
          timestamp: DateTime(2026, 1, 1),
          isRead: false,
        ),
      ];

      final controller =
      StreamController<List<Message>>();

      when(
            () => repository.getUserMessages('user1'),
      ).thenAnswer(
            (_) => controller.stream,
      );

      final stream = useCase('user1');

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
            () => repository.getUserMessages('user1'),
      ).called(1);
    },
  );
}