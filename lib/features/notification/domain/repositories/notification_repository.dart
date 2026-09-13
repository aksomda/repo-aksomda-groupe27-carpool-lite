import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Stream<List<AppNotification>> getNotifications(
      String userId,
      );

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  });

  Future<void> markAllAsRead(
      String userId,
      );

  Future<void> saveFcmToken({
    required String userId,
    required String token,
  });
}