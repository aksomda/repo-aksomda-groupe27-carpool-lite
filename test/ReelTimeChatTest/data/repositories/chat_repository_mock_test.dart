import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/chat/data/datasources/firebase_chat_datasource.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/chat/data/repositories_impl/chat_repository_impl.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirebaseChatDataSource dataSource;
  late ChatRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();

    dataSource = FirebaseChatDataSource(
      firestore: firestore,
    );

    repository = ChatRepositoryImpl(
      dataSource: dataSource,
    );
  });

  group('ChatRepositoryImpl', () {
    test(
      'doit envoyer un message dans Firestore',
          () async {
        await repository.sendMessage(
          text: 'Bonjour',
          senderId: 'user1',
          receiverId: 'user2',
        );

        final snapshot =
        await firestore.collection('messages').get();

        expect(snapshot.docs.length, 1);

        final data = snapshot.docs.first.data();

        expect(data['senderId'], 'user1');
        expect(data['receiverId'], 'user2');
        expect(data['text'], 'Bonjour');
        expect(data['isRead'], false);
        expect(
          data['participants'],
          containsAll(['user1', 'user2']),
        );
      },
    );

    test(
      'ne doit pas envoyer un message vide',
          () async {
        await repository.sendMessage(
          text: '   ',
          senderId: 'user1',
          receiverId: 'user2',
        );

        final snapshot =
        await firestore.collection('messages').get();

        expect(snapshot.docs, isEmpty);
      },
    );

    test(
      'doit récupérer une conversation',
          () async {
        await firestore
            .collection('messages')
            .add({
          'senderId': 'user1',
          'receiverId': 'user2',
          'text': 'Bonjour',
          'timestamp': Timestamp.fromDate(
            DateTime(2026, 1, 1, 10),
          ),
          'isRead': false,
          'type': 'text',
          'participants': [
            'user1',
            'user2',
          ],
        });

        await firestore
            .collection('messages')
            .add({
          'senderId': 'user2',
          'receiverId': 'user1',
          'text': 'Salut',
          'timestamp': Timestamp.fromDate(
            DateTime(2026, 1, 1, 11),
          ),
          'isRead': false,
          'type': 'text',
          'participants': [
            'user1',
            'user2',
          ],
        });

        final messages = await repository
            .getMessagesStream(
          currentUserId: 'user1',
          contactId: 'user2',
        )
            .first;

        expect(messages.length, 2);

        expect(
          messages[0].text,
          'Bonjour',
        );

        expect(
          messages[1].text,
          'Salut',
        );
      },
    );

    test(
      'ne doit pas récupérer les messages d une autre conversation',
          () async {
        await firestore
            .collection('messages')
            .add({
          'senderId': 'user1',
          'receiverId': 'user2',
          'text': 'Bonjour user2',
          'timestamp': Timestamp.fromDate(
            DateTime(2026, 1, 1),
          ),
          'isRead': false,
          'type': 'text',
          'participants': [
            'user1',
            'user2',
          ],
        });

        await firestore
            .collection('messages')
            .add({
          'senderId': 'user1',
          'receiverId': 'user3',
          'text': 'Bonjour user3',
          'timestamp': Timestamp.fromDate(
            DateTime(2026, 1, 2),
          ),
          'isRead': false,
          'type': 'text',
          'participants': [
            'user1',
            'user3',
          ],
        });

        final messages = await repository
            .getMessagesStream(
          currentUserId: 'user1',
          contactId: 'user2',
        )
            .first;

        expect(messages.length, 1);
        expect(
          messages.first.receiverId,
          'user2',
        );
      },
    );
  });

  test(
    'doit marquer uniquement les messages reçus comme lus',
        () async {
      final message1 = await firestore
          .collection('messages')
          .add({
        'senderId': 'user2',
        'receiverId': 'user1',
        'text': 'Message reçu',
        'timestamp': Timestamp.fromDate(
          DateTime(2026, 1, 1),
        ),
        'isRead': false,
        'type': 'text',
        'participants': [
          'user1',
          'user2',
        ],
      });

      final message2 = await firestore
          .collection('messages')
          .add({
        'senderId': 'user1',
        'receiverId': 'user2',
        'text': 'Mon message',
        'timestamp': Timestamp.fromDate(
          DateTime(2026, 1, 1),
        ),
        'isRead': false,
        'type': 'text',
        'participants': [
          'user1',
          'user2',
        ],
      });

      await repository.markConversationAsRead(
        currentUserId: 'user1',
        contactId: 'user2',
      );

      final received =
      await firestore
          .collection('messages')
          .doc(message1.id)
          .get();

      final sent =
      await firestore
          .collection('messages')
          .doc(message2.id)
          .get();

      expect(
        received.data()?['isRead'],
        true,
      );

      expect(
        sent.data()?['isRead'],
        false,
      );
    },
  );

  test(
    'doit recevoir les nouveaux messages en temps réel',
        () async {
      final stream = repository.getMessagesStream(
        currentUserId: 'user1',
        contactId: 'user2',
      );

      final future = stream.skip(1).first;

      await firestore
          .collection('messages')
          .add({
        'senderId': 'user2',
        'receiverId': 'user1',
        'text': 'Nouveau message',
        'timestamp': Timestamp.fromDate(
          DateTime(2026, 1, 1),
        ),
        'isRead': false,
        'type': 'text',
        'participants': [
          'user1',
          'user2',
        ],
      });

      final messages = await future;

      expect(
        messages.any(
              (message) =>
          message.text == 'Nouveau message',
        ),
        true,
      );
    },
  );
}