import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

class GetNotifications {
  final NotificationRepository repository;

  GetNotifications(this.repository);

  Stream<List<AppNotification>> call(
      String userId,
      ) {
    return repository.getNotifications(userId);
  }
}