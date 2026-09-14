import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ProfileEntity> getProfile(String uid) {
    return remoteDataSource.getUserById(uid);
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) {
    final model = ProfileModel(
      uid: profile.uid,
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
      sex: profile.sex,
      universityId: profile.universityId,
      campusId: profile.campusId,
      isVerified: profile.isVerified,
    );
    return remoteDataSource.updateProfile(model);
  }
}