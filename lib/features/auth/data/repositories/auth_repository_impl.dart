import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<UserEntity> signUp({
    required String name,
    required String email,
    required String password,
    String? universityId,
    String? campusId,
  }) async {
    return await remoteDataSource.signUp(
      name: name,
      email: email,
      password: password,
      universityId: universityId,
      campusId: campusId,
    );
  }

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.signIn(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  @override
  Future<bool> verifyStudent({
    required String uid,
    required String studentId,
  }) async {
    return await remoteDataSource.verifyStudent(
      uid: uid,
      studentId: studentId,
    );
  }
}