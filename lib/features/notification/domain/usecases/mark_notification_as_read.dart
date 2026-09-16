import '../repositories/notification_repository.dart';

class MarkNotificationAsRead {
  final NotificationRepository repository;

  MarkNotificationAsRead(this.repository);

  Future<void> call({
    required String userId,
    required String notificationId,
  }) {
    return repository.markAsRead(
      userId: userId,
      notificationId: notificationId,
    );
  }
}