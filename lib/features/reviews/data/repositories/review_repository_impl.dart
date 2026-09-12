import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  ReviewModel _toModel(Review review, {String? overrideId}) {
    return ReviewModel(
      id: overrideId ?? review.id,
      tripId: review.tripId,
      bookingId: review.bookingId,
      reviewerId: review.reviewerId,
      reviewedUserId: review.reviewedUserId,
      universityId: review.universityId,
      punctualityRating: review.punctualityRating,
      drivingRating: review.drivingRating,
      atmosphereRating: review.atmosphereRating,
      overallRating: review.overallRating,
      comment: review.comment,
      createdAt: review.createdAt,
    );
  }

  @override
  Future<Review> createReview(Review review) async {
    final id = review.id.isNotEmpty
        ? review.id
        : remoteDataSource.newReviewId();

    final model = _toModel(review, overrideId: id);
    await remoteDataSource.createReview(model);
    return model;
  }

  @override
  Future<List<Review>> getReviewsByDriver(String driverId) {
    return remoteDataSource.getReviewsByDriver(driverId);
  }

  @override
  Future<List<Review>> getReviewsByTrip(String tripId) {
    return remoteDataSource.getReviewsByTrip(tripId);
  }

  @override
  Future<List<Review>> getAllReviews() {
    return remoteDataSource.getAllReviews();
  }
}
