import '../entities/review.dart';

abstract class ReviewRepository {
  /// Crée un avis. [review.id] peut être vide : un identifiant Firestore
  /// est alors généré par l'implémentation, et l'avis persisté (avec son
  /// id définitif) est retourné.
  Future<Review> createReview(Review review);

  Future<List<Review>> getReviewsByDriver(String driverId);

  Future<List<Review>> getReviewsByTrip(String tripId);

  Future<List<Review>> getAllReviews();
}
