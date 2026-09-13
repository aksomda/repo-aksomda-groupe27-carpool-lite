import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/notification/data/datasources/firebase_notification_datasource.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/notification/data/model/notification_model.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/notification/data/repositories_impl/notification_repository_impl.dart';

class MockFirebaseNotificationDataSource extends Mock
    implements FirebaseNotificationDataSource {}

void main() {
  late MockFirebaseNotificationDataSource dataSource;
  late NotificationRepositoryImpl repository;

  setUp(() {
    dataSource = MockFirebaseNotificationDataSource();

    repository = NotificationRepositoryImpl(
      dataSource: dataSource,
    );
  });

  test(
    'getNotifications doit récupérer les notifications du DataSource',
        () async {
      final notifications = [
        NotificationModel(
          id: 'notification1',
          title: 'Nouveau message',
          body: 'Jean vous a envoyé un message',
          type: 'chat',
          senderId: 'user2',
          receiverId: 'user1',
          chatId: 'chat1',
          isRead: false,
          createdAt: DateTime(2026, 9, 10),
        ),
      ];

      when(
            () => dataSource.getNotifications('user1'),
      ).thenAnswer(
            (_) => Stream.value(notifications),
      );

      final result = repository.getNotifications('user1');

      final received = await result.first;

      expect(received.length, 1);
      expect(received.first.id, 'notification1');
      expect(received.first.title, 'Nouveau message');
      expect(received.first.isRead, false);

      verify(
            () => dataSource.getNotifications('user1'),
      ).called(1);
    },
  );

  test(
    'markAsRead doit appeler le DataSource',
        () async {
      when(
            () => dataSource.markAsRead(
          userId: 'user1',
          notificationId: 'notification1',
        ),
      ).thenAnswer((_) async {});

      await repository.markAsRead(
        userId: 'user1',
        notificationId: 'notification1',
      );

      verify(
            () => dataSource.markAsRead(
          userId: 'user1',
          notificationId: 'notification1',
        ),
      ).called(1);
    },
  );

  test(
    'markAllAsRead doit appeler le DataSource',
        () async {
      when(
            () => dataSource.markAllAsRead('user1'),
      ).thenAnswer((_) async {});

      await repository.markAllAsRead('user1');

      verify(
            () => dataSource.markAllAsRead('user1'),
      ).called(1);
    },
  );

  test(
    'saveFcmToken doit appeler le DataSource',
        () async {
      when(
            () => dataSource.saveFcmToken(
          userId: 'user1',
          token: 'token123',
        ),
      ).thenAnswer((_) async {});

      await repository.saveFcmToken(
        userId: 'user1',
        token: 'token123',
      );

      verify(
            () => dataSource.saveFcmToken(
          userId: 'user1',
          token: 'token123',
        ),
      ).called(1);
    },
  );
}