import '../repositories/university_repository.dart';
import '../entities/university_entity.dart';

class GetUniversitiesUseCase {
  final UniversityRepository repository;

  GetUniversitiesUseCase(this.repository);

  Stream<List<UniversityEntity>> call() {
    return repository.getUniversities();
  }
}