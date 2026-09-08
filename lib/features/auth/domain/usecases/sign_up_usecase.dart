import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUserCase {
  final AuthRepository repository;

  SignUpUserCase(this.repository);

  Future<UserEntity> call({
    required String name,
    required String email,
    required String password,
    String? universityId,
    String? campusId,
  }) async {
    return await repository.signUp(
      name: name,
      email: email,
      password: password,
      universityId: universityId,
      campusId: campusId,
    );
  }
}