import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trip_model.dart';

class TripsRemoteDataSource {
  final FirebaseFirestore firestore;

  TripsRemoteDataSource(this.firestore);

  Future<TripModel> publishTrip(TripModel trip) async {
    final document = firestore.collection('trips').doc();

    await document.set(trip.toFirestore());

    return TripModel.fromFirestore(await document.get());
  }

  Future<List<TripModel>> searchTrips({
    required String departureLabel,
    required String universityId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);

    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await firestore
        .collection('trips')
        .where('departureLabel', isEqualTo: departureLabel)
        .where('universityId', isEqualTo: universityId)
        .where('departureDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('departureDateTime', isLessThan: Timestamp.fromDate(endOfDay))
        .where('status', isEqualTo: 'available')
        .get();

    return snapshot.docs.map((document) => TripModel.fromFirestore(document)).toList();
  }

  Future<List<TripModel>> getTripHistory(String userId) async {
    final snapshot = await firestore
        .collection('trips')
        .where('driverId', isEqualTo: userId)
        .orderBy('departureDateTime', descending: true)
        .get();

    return snapshot.docs.map((document) => TripModel.fromFirestore(document)).toList();
  }

  Future<void> cancelTrip(String tripId) async {
    await firestore.collection('trips').doc(tripId).update({'status': 'cancelled'});
  }
}
