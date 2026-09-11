import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/notification/domain/repositories/notification_repository.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/notification/domain/usecases/save_fcm_token.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository repository;
  late SaveFcmToken saveFcmToken;

  setUp(() {
    repository = MockNotificationRepository();

    saveFcmToken = SaveFcmToken(
      repository,
    );
  });

  test(
    'doit enregistrer le token FCM de l’utilisateur',
        () async {
      when(
            () => repository.saveFcmToken(
          userId: 'user1',
          token: 'fcm-token-123',
        ),
      ).thenAnswer((_) async {});

      await saveFcmToken(
        userId: 'user1',
        token: 'fcm-token-123',
      );

      verify(
            () => repository.saveFcmToken(
          userId: 'user1',
          token: 'fcm-token-123',
        ),
      ).called(1);
    },
  );
}