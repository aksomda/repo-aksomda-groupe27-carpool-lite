// ReviewModel : mapping Firestore <-> Review.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.tripId,
    required super.bookingId,
    required super.reviewerId,
    required super.reviewedUserId,
    required super.universityId,
    required super.punctualityRating,
    required super.drivingRating,
    required super.atmosphereRating,
    required super.overallRating,
    super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ReviewModel(
      id: id,
      tripId: data['tripId'] ?? '',
      bookingId: data['bookingId'] ?? '',
      reviewerId: data['reviewerId'] ?? '',
      reviewedUserId: data['reviewedUserId'] ?? '',
      universityId: data['universityId'] ?? '',
      punctualityRating: data['punctualityRating'] ?? 0,
      drivingRating: data['drivingRating'] ?? 0,
      atmosphereRating: data['atmosphereRating'] ?? 0,
      overallRating: data['overallRating'] ?? 0,
      comment: data['comment'],
      createdAt: _parseCreatedAt(data['createdAt']),
    );
  }

  /// Accepte soit un [Timestamp] Firestore (nouvelles écritures), soit une
  /// chaîne ISO 8601 (anciens documents), pour ne pas planter sur les
  /// données déjà enregistrées avec l'ancien format.
  static DateTime _parseCreatedAt(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tripId': tripId,
      'bookingId': bookingId,
      'reviewerId': reviewerId,
      'reviewedUserId': reviewedUserId,
      'universityId': universityId,
      'punctualityRating': punctualityRating,
      'drivingRating': drivingRating,
      'atmosphereRating': atmosphereRating,
      'overallRating': overallRating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
