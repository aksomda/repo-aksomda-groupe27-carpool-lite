import '../repositories/auth_repository.dart';

class CheckEmailVerificationUseCase {
  final AuthRepository repository;

  CheckEmailVerificationUseCase(this.repository);

  Future<bool> call() => repository.checkEmailVerification();
}
