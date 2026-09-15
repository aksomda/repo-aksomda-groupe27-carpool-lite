import '../repositories/auth_repository.dart';

class VerifyStudentUseCase {
  final AuthRepository repository;

  VerifyStudentUseCase(this.repository);

  Future<bool> call({
    required String uid,
    required String studentId,
  }) async {
    return await repository.verifyStudent(
      uid: uid,
      studentId: studentId,
    );
  }
}