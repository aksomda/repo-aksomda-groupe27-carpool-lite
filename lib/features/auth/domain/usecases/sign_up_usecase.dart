import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUserCase {
  final AuthRepository repository;

  SignUpUserCase(this.repository);

  Future<UserEntity> call({
    required String name,
    required String email,
    required String password,
    required String phone,
    required Sex sex,
    String? universityId,
    String? campusId,
  }) async {
    return await repository.signUp(
      name: name,
      email: email,
      password: password,
      phone: phone,
      sex: sex,
      universityId: universityId,
      campusId: campusId,
    );
  }
}
