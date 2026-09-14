import '../repositories/notification_repository.dart';

class SaveFcmToken {
  final NotificationRepository repository;

  SaveFcmToken(this.repository);

  Future<void> call({
    required String userId,
    required String token,
  }) {
    return repository.saveFcmToken(
      userId: userId,
      token: token,
    );
  }
}