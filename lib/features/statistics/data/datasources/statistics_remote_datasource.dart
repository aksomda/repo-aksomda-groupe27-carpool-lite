// Agrégation des données Firestore (reviews, trips, users, universities).
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../reviews/data/models/review_model.dart';
import '../../../reviews/domain/entities/review.dart';

class StatisticsRemoteDataSource {
  final FirebaseFirestore firestore;

  StatisticsRemoteDataSource({required this.firestore});

  Future<List<Review>> getReviewsByDriver(String driverId) async {
    final snapshot = await firestore
        .collection('reviews')
        .where('reviewedUserId', isEqualTo: driverId)
        .get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<List<Review>> getReviewsByUniversity(String universityId) async {
    final snapshot = await firestore
        .collection('reviews')
        .where('universityId', isEqualTo: universityId)
        .get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<int> getTotalTrips(String universityId) async {
    final snapshot = await firestore
        .collection('trips')
        .where('universityId', isEqualTo: universityId)
        .get();

    return snapshot.size;
  }

  Future<int> getTotalDrivers(String universityId) async {
    final snapshot = await firestore
        .collection('users')
        .where('universityId', isEqualTo: universityId)
        .where('role', isEqualTo: 'driver')
        .get();

    return snapshot.size;
  }

  /// Nom affichable d'un utilisateur (conducteur), vide si introuvable.
  Future<String> getUserName(String userId) async {
    if (userId.isEmpty) return '';
    final doc = await firestore.collection('users').doc(userId).get();
    return (doc.data()?['name'] as String?) ?? '';
  }

  /// Nom affichable d'une université, vide si introuvable.
  Future<String> getUniversityName(String universityId) async {
    if (universityId.isEmpty) return '';
    final doc =
        await firestore.collection('universities').doc(universityId).get();
    return (doc.data()?['name'] as String?) ?? '';
  }
}
