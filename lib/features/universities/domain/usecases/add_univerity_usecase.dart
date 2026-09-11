import '../repositories/university_repository.dart';
import '../entities/university_entity.dart';

class AddUniversityUseCase {
  final UniversityRepository repository;

  AddUniversityUseCase(this.repository);

  Future<void> call(UniversityEntity university) {
    return repository.createUniversity(university);
  }
}