import '../entities/university_entity.dart';

abstract class UniversityRepository {
  Stream<List<UniversityEntity>> getUniversities();
  Future<void> createUniversity(UniversityEntity university);
}