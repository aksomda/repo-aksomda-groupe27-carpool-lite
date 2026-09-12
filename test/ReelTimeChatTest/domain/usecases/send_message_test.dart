import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/ReelTimeChat/domain/repositories/chat_repository.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/ReelTimeChat/domain/usecases/send_message.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repository;
  late SendMessage useCase;

  setUp(() {
    repository = MockChatRepository();
    useCase = SendMessage(repository);
  });

  group('SendMessage', () {
    test(
      'doit envoyer un message avec les bons paramètres',
          () async {
        when(
              () => repository.sendMessage(
            text: any(named: 'text'),
            senderId: any(named: 'senderId'),
            receiverId: any(named: 'receiverId'),
          ),
        ).thenAnswer((_) async {});

        await useCase(
          text: 'Bonjour',
          senderId: 'user1',
          receiverId: 'user2',
        );

        verify(
              () => repository.sendMessage(
            text: 'Bonjour',
            senderId: 'user1',
            receiverId: 'user2',
          ),
        ).called(1);
      },
    );

    test(
      'doit propager une erreur du repository',
          () async {
        when(
              () => repository.sendMessage(
            text: any(named: 'text'),
            senderId: any(named: 'senderId'),
            receiverId: any(named: 'receiverId'),
          ),
        ).thenThrow(Exception('Erreur Firebase'));

        expect(
              () => useCase(
            text: 'Bonjour',
            senderId: 'user1',
            receiverId: 'user2',
          ),
          throwsException,
        );
      },
    );
  });
}