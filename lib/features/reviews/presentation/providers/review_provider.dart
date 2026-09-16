// Gestion d'état des évaluations.
import 'package:flutter/foundation.dart';

import '../../domain/entities/review.dart';
import '../../domain/usecases/create_review.dart';
import '../../domain/usecases/get_reviews_for_user_usecase.dart';

class ReviewProvider extends ChangeNotifier {
  final CreateReview createReviewUseCase;
  final GetReviewsForUserUseCase getReviewsForUserUseCase;

  ReviewProvider({
    required this.createReviewUseCase,
    required this.getReviewsForUserUseCase,
  });

  bool isSubmitting = false;
  String? submitError;

  bool isLoadingReviews = false;
  String? loadError;
  List<Review> receivedReviews = const [];

  /// Publie un avis. Retourne `true` en cas de succès.
  Future<bool> submitReview({
    required String tripId,
    required String bookingId,
    required String reviewerId,
    required String reviewedUserId,
    required String universityId,
    required int punctualityRating,
    required int drivingRating,
    required int atmosphereRating,
    required int overallRating,
    String? comment,
  }) async {
    isSubmitting = true;
    submitError = null;
    notifyListeners();

    try {
      final review = Review(
        id: '',
        tripId: tripId,
        bookingId: bookingId,
        reviewerId: reviewerId,
        reviewedUserId: reviewedUserId,
        universityId: universityId,
        punctualityRating: punctualityRating,
        drivingRating: drivingRating,
        atmosphereRating: atmosphereRating,
        overallRating: overallRating,
        comment: (comment == null || comment.trim().isEmpty) ? null : comment.trim(),
        createdAt: DateTime.now(),
      );

      final created = await createReviewUseCase(review);
      receivedReviews = [created, ...receivedReviews];
      return true;
    } catch (e) {
      submitError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  /// Charge les avis reçus par [userId] en tant que conducteur.
  Future<void> loadReviewsForUser(String userId) async {
    isLoadingReviews = true;
    loadError = null;
    notifyListeners();

    try {
      receivedReviews = await getReviewsForUserUseCase(userId);
    } catch (e) {
      loadError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingReviews = false;
      notifyListeners();
    }
  }
}
