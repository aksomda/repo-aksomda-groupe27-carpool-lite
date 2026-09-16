import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firebase_notification_datasource.dart';
import '../../data/repositories_impl/notification_repository_impl.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_notification_as_read.dart';
import '../../domain/usecases/save_fcm_token.dart';
import '../../domain/usecases/send_notification.dart';

final notificationDataSourceProvider =
Provider<FirebaseNotificationDataSource>((ref) {
  return FirebaseNotificationDataSource();
});

final notificationRepositoryProvider =
Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    dataSource: ref.watch(
      notificationDataSourceProvider,
    ),
  );
});

final getNotificationsProvider =
Provider<GetNotifications>((ref) {
  return GetNotifications(
    ref.watch(notificationRepositoryProvider),
  );
});

final markNotificationAsReadProvider =
Provider<MarkNotificationAsRead>((ref) {
  return MarkNotificationAsRead(
    ref.watch(notificationRepositoryProvider),
  );
});

final saveFcmTokenProvider =
Provider<SaveFcmToken>((ref) {
  return SaveFcmToken(
    ref.watch(notificationRepositoryProvider),
  );
});

final sendNotificationUseCaseProvider =
Provider<SendNotification>((ref) {
  return SendNotification(
    ref.watch(notificationRepositoryProvider),
  );
});

final sendNotificationProvider =
Provider<Future<void> Function({
  required String senderId,
  required String receiverId,
  required String title,
  required String body,
})>((ref) {
  final useCase = ref.watch(
    sendNotificationUseCaseProvider,
  );

  return ({
    required String senderId,
    required String receiverId,
    required String title,
    required String body,
  }) {
    return useCase(
      senderId: senderId,
      receiverId: receiverId,
      title: title,
      body: body,
    );
  };
});

final notificationsStreamProvider =
StreamProvider.family<List<AppNotification>, String>(
      (ref, userId) {
    return ref
        .watch(getNotificationsProvider)
        .call(userId);
  },
);