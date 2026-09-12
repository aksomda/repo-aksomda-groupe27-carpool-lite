// Accès à la collection reviews dans Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review_model.dart';

class ReviewRemoteDataSource {
  final FirebaseFirestore firestore;

  ReviewRemoteDataSource(this.firestore);

  CollectionReference<Map<String, dynamic>> get _reviews =>
      firestore.collection('reviews');

  /// Génère un identifiant Firestore avant écriture, pour pouvoir le
  /// connaître côté client (ex. navigation, confirmation) avant le `set`.
  String newReviewId() => _reviews.doc().id;

  Future<void> createReview(ReviewModel review) async {
    await _reviews.doc(review.id).set(review.toFirestore());
  }

  Future<List<ReviewModel>> getReviewsByDriver(String driverId) async {
    final snapshot = await _reviews
        .where('reviewedUserId', isEqualTo: driverId)
        .get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<List<ReviewModel>> getReviewsByTrip(String tripId) async {
    final snapshot = await _reviews.where('tripId', isEqualTo: tripId).get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<List<ReviewModel>> getAllReviews() async {
    final snapshot = await _reviews.get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
