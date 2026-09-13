import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/firebase_notification_datasource.dart';

class NotificationRepositoryImpl
    implements NotificationRepository {
  final FirebaseNotificationDataSource dataSource;

  NotificationRepositoryImpl({
    required this.dataSource,
  });

  @override
  Stream<List<AppNotification>> getNotifications(
      String userId,
      ) {
    return dataSource
        .getNotifications(userId)
        .map(
          (notifications) => notifications
          .map((notification) => notification.toEntity())
          .toList(),
    );
  }

  @override
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) {
    return dataSource.markAsRead(
      userId: userId,
      notificationId: notificationId,
    );
  }

  @override
  Future<void> markAllAsRead(
      String userId,
      ) {
    return dataSource.markAllAsRead(userId);
  }

  @override
  Future<void> saveFcmToken({
    required String userId,
    required String token,
  }) {
    return dataSource.saveFcmToken(
      userId: userId,
      token: token,
    );
  }
}