import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/notification/domain/entities/app_notification.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/notification/domain/repositories/notification_repository.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/notification/domain/usecases/get_notifications.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository repository;
  late GetNotifications getNotifications;

  setUp(() {
    repository = MockNotificationRepository();
    getNotifications = GetNotifications(repository);
  });

  test(
    'doit récupérer les notifications de l’utilisateur',
        () async {
      final notifications = [
        AppNotification(
          id: 'notification1',
          title: 'Nouveau message',
          body: 'Jean vous a envoyé un message',
          type: 'chat',
          senderId: 'user2',
          receiverId: 'user1',
          chatId: 'chat1',
          isRead: false,
          createdAt: DateTime(2026, 9, 10, 10),
        ),
        AppNotification(
          id: 'notification2',
          title: 'Nouveau trajet',
          body: 'Un nouveau trajet est disponible',
          type: 'trip',
          receiverId: 'user1',
          isRead: true,
          createdAt: DateTime(2026, 9, 10, 9),
        ),
      ];

      when(
            () => repository.getNotifications('user1'),
      ).thenAnswer(
            (_) => Stream.value(notifications),
      );

      final result = getNotifications('user1');

      final received = await result.first;

      expect(received, notifications);
      expect(received.length, 2);
      expect(received.first.title, 'Nouveau message');

      verify(
            () => repository.getNotifications('user1'),
      ).called(1);
    },
  );

  test(
    'doit retourner une liste vide lorsqu’il n’y a aucune notification',
        () async {
      when(
            () => repository.getNotifications('user1'),
      ).thenAnswer(
            (_) => Stream.value([]),
      );

      final result = getNotifications('user1');

      final notifications = await result.first;

      expect(notifications, isEmpty);
    },
  );
}