import '../../domain/entities/university_entity.dart';
import '../../domain/repositories/university_repository.dart';
import '../datasources/university_remote_datasource.dart';
import '../models/university_model.dart';

class UniversityRepositoryImpl implements UniversityRepository {
  final UniversityRemoteDataSource remoteDataSource;

  UniversityRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<UniversityEntity>> getUniversities() {
    return remoteDataSource.getUniversities();
  }

  @override
  Future<void> createUniversity(UniversityEntity university) {
    final model = UniversityModel(
      id: university.id,
      name: university.name,
      city: university.city,
      latitude: university.latitude,
      longitude: university.longitude,
      address: university.address,
    );
    return remoteDataSource.createUniversity(model);
  }
}