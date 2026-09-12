import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/notification/domain/repositories/notification_repository.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/notification/domain/usecases/mark_notification_as_read.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository repository;
  late MarkNotificationAsRead markNotificationAsRead;

  setUp(() {
    repository = MockNotificationRepository();

    markNotificationAsRead = MarkNotificationAsRead(
      repository,
    );
  });

  test(
    'doit marquer une notification comme lue',
        () async {
      when(
            () => repository.markAsRead(
          userId: 'user1',
          notificationId: 'notification1',
        ),
      ).thenAnswer((_) async {});

      await markNotificationAsRead(
        userId: 'user1',
        notificationId: 'notification1',
      );

      verify(
            () => repository.markAsRead(
          userId: 'user1',
          notificationId: 'notification1',
        ),
      ).called(1);
    },
  );
}