import '../repositories/notification_repository.dart';

class SendNotification {
  final NotificationRepository repository;

  SendNotification(this.repository);

  Future<void> call({
    required String senderId,
    required String receiverId,
    required String title,
    required String body,
  }) {
    return repository.sendNotification(
      senderId: senderId,
      receiverId: receiverId,
      title: title,
      body: body,
    );
  }
}
