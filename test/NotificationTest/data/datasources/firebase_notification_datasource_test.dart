import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repo_aksomda_groupe27_carpool_lite/features/notification/data/datasources/firebase_notification_datasource.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirebaseNotificationDataSource dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();

    dataSource = FirebaseNotificationDataSource(
      firestore: firestore,
    );
  });

  group('getNotifications', () {
    test(
      'doit récupérer les notifications de l’utilisateur',
          () async {
        final userNotifications = firestore
            .collection('users')
            .doc('user1')
            .collection('notifications');

        await userNotifications.add({
          'title': 'Nouveau message',
          'body': 'Jean vous a envoyé un message',
          'type': 'chat',
          'senderId': 'user2',
          'receiverId': 'user1',
          'chatId': 'chat1',
          'isRead': false,
          'createdAt': Timestamp.fromDate(
            DateTime(2026, 9, 10, 10),
          ),
          'data': {
            'screen': 'chat',
          },
        });

        final notifications =
        await dataSource.getNotifications('user1').first;

        expect(notifications.length, 1);

        expect(
          notifications.first.title,
          'Nouveau message',
        );

        expect(
          notifications.first.body,
          'Jean vous a envoyé un message',
        );

        expect(
          notifications.first.type,
          'chat',
        );

        expect(
          notifications.first.isRead,
          false,
        );

        expect(
          notifications.first.senderId,
          'user2',
        );

        expect(
          notifications.first.receiverId,
          'user1',
        );
      },
    );

    test(
      'doit trier les notifications de la plus récente à la plus ancienne',
          () async {
        final notifications = firestore
            .collection('users')
            .doc('user1')
            .collection('notifications');

        await notifications.add({
          'title': 'Ancienne notification',
          'body': 'Ancienne',
          'type': 'general',
          'isRead': false,
          'createdAt': Timestamp.fromDate(
            DateTime(2026, 9, 10, 8),
          ),
          'data': {},
        });

        await notifications.add({
          'title': 'Nouvelle notification',
          'body': 'Nouvelle',
          'type': 'general',
          'isRead': false,
          'createdAt': Timestamp.fromDate(
            DateTime(2026, 9, 10, 12),
          ),
          'data': {},
        });

        final result =
        await dataSource.getNotifications('user1').first;

        expect(result.length, 2);

        expect(
          result.first.title,
          'Nouvelle notification',
        );

        expect(
          result.last.title,
          'Ancienne notification',
        );
      },
    );

    test(
      'ne doit pas récupérer les notifications d’un autre utilisateur',
          () async {
        await firestore
            .collection('users')
            .doc('user1')
            .collection('notifications')
            .add({
          'title': 'Notification user1',
          'body': 'Bonjour user1',
          'type': 'general',
          'isRead': false,
          'createdAt': Timestamp.now(),
          'data': {},
        });

        await firestore
            .collection('users')
            .doc('user2')
            .collection('notifications')
            .add({
          'title': 'Notification user2',
          'body': 'Bonjour user2',
          'type': 'general',
          'isRead': false,
          'createdAt': Timestamp.now(),
          'data': {},
        });

        final result =
        await dataSource.getNotifications('user1').first;

        expect(result.length, 1);
        expect(
          result.first.title,
          'Notification user1',
        );
      },
    );
  });

  group('markAsRead', () {
    test(
      'doit passer isRead à true',
          () async {
        final reference = await firestore
            .collection('users')
            .doc('user1')
            .collection('notifications')
            .add({
          'title': 'Nouveau message',
          'body': 'Bonjour',
          'type': 'chat',
          'isRead': false,
          'createdAt': Timestamp.now(),
          'data': {},
        });

        await dataSource.markAsRead(
          userId: 'user1',
          notificationId: reference.id,
        );

        final document = await firestore
            .collection('users')
            .doc('user1')
            .collection('notifications')
            .doc(reference.id)
            .get();

        expect(
          document.data()!['isRead'],
          true,
        );
      },
    );
  });

  group('markAllAsRead', () {
    test(
      'doit marquer toutes les notifications non lues comme lues',
          () async {
        final notifications = firestore
            .collection('users')
            .doc('user1')
            .collection('notifications');

        await notifications.add({
          'title': 'Notification 1',
          'body': 'Message 1',
          'type': 'chat',
          'isRead': false,
          'createdAt': Timestamp.now(),
          'data': {},
        });

        await notifications.add({
          'title': 'Notification 2',
          'body': 'Message 2',
          'type': 'chat',
          'isRead': false,
          'createdAt': Timestamp.now(),
          'data': {},
        });

        await notifications.add({
          'title': 'Notification déjà lue',
          'body': 'Message 3',
          'type': 'chat',
          'isRead': true,
          'createdAt': Timestamp.now(),
          'data': {},
        });

        await dataSource.markAllAsRead('user1');

        final snapshot = await notifications.get();

        for (final doc in snapshot.docs) {
          expect(
            doc.data()['isRead'],
            true,
          );
        }
      },
    );

    test(
      'ne doit rien faire s’il n’y a aucune notification non lue',
          () async {
        await firestore
            .collection('users')
            .doc('user1')
            .collection('notifications')
            .add({
          'title': 'Déjà lue',
          'body': 'Bonjour',
          'type': 'general',
          'isRead': true,
          'createdAt': Timestamp.now(),
          'data': {},
        });

        await dataSource.markAllAsRead('user1');

        final snapshot = await firestore
            .collection('users')
            .doc('user1')
            .collection('notifications')
            .get();

        expect(snapshot.docs.length, 1);
        expect(
          snapshot.docs.first.data()['isRead'],
          true,
        );
      },
    );
  });

  group('saveFcmToken', () {
    test(
      'doit enregistrer le token FCM dans le document utilisateur',
          () async {
        await dataSource.saveFcmToken(
          userId: 'user1',
          token: 'token123',
        );

        final user = await firestore
            .collection('users')
            .doc('user1')
            .get();

        final tokens =
        List<String>.from(user.data()!['fcmTokens']);

        expect(
          tokens,
          contains('token123'),
        );
      },
    );

    test(
      'ne doit pas créer de doublon avec le même token',
          () async {
        await dataSource.saveFcmToken(
          userId: 'user1',
          token: 'token123',
        );

        await dataSource.saveFcmToken(
          userId: 'user1',
          token: 'token123',
        );

        final user = await firestore
            .collection('users')
            .doc('user1')
            .get();

        final tokens =
        List<String>.from(user.data()!['fcmTokens']);

        expect(
          tokens.where((token) => token == 'token123').length,
          1,
        );
      },
    );
  });

  test(
    'le stream doit recevoir une nouvelle notification en temps réel',
        () async {
      final notifications = firestore
          .collection('users')
          .doc('user1')
          .collection('notifications');

      final stream = dataSource.getNotifications('user1');

      final future = stream.skip(1).first;

      await notifications.add({
        'title': 'Nouvelle notification',
        'body': 'Vous avez reçu une notification',
        'type': 'chat',
        'senderId': 'user2',
        'receiverId': 'user1',
        'chatId': 'chat1',
        'isRead': false,
        'createdAt': Timestamp.now(),
        'data': {},
      });

      final result = await future;

      expect(result.length, 1);

      expect(
        result.first.title,
        'Nouvelle notification',
      );
    },
  );
}