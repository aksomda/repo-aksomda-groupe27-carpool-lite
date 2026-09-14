// Cas d'usage : récupérer les avis reçus par un utilisateur (en tant que
// conducteur évalué par ses passagers).
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetReviewsForUserUseCase {
  final ReviewRepository repository;

  GetReviewsForUserUseCase(this.repository);

  Future<List<Review>> call(String userId) {
    return repository.getReviewsByDriver(userId);
  }
}
