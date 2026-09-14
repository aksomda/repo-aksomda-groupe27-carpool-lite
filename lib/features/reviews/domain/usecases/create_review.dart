// Cas d'usage : évaluation après un trajet (fonctionnalité 10).
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class CreateReview {
  final ReviewRepository repository;

  CreateReview(this.repository);

  Future<Review> call(Review review) async {
    _validateRating(review.punctualityRating);
    _validateRating(review.drivingRating);
    _validateRating(review.atmosphereRating);
    _validateRating(review.overallRating);

    return repository.createReview(review);
  }

  void _validateRating(int rating) {
    if (rating < 1 || rating > 10) {
      throw Exception('La note doit être comprise entre 1 et 10.');
    }
  }
}
