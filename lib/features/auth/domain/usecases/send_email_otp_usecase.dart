import '../repositories/auth_repository.dart';

class SendEmailOtpUseCase {
  final AuthRepository repository;

  SendEmailOtpUseCase(this.repository);

  Future<void> call() => repository.sendEmailVerification();
}
