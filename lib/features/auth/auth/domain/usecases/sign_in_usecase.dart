import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUserCase {
  final AuthRepository repository;

  SignInUserCase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    return await repository.signIn(
      email: email,
      password: password,
    );
  }
}