import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trip_entity.dart';
import '../models/trip_model.dart';

class TripRemoteDataSource {
  final FirebaseFirestore firestore;

  TripRemoteDataSource({
    required this.firestore,
  });

  CollectionReference<Map<String, dynamic>>
      get _tripsCollection {
    return firestore.collection('trips');
  }

  Future<TripModel> publishTrip({
    required String driverId,
    required String departure,
    required String arrival,

    required double departureLatitude,
    required double departureLongitude,

    required double arrivalLatitude,
    required double arrivalLongitude,

    required DateTime departureDateTime,
    required double pricePerSeat,
    required int totalSeats,
  }) async {
    if (driverId.isEmpty) {
      throw Exception('Conducteur non identifié.');
    }

    if (departure.trim().isEmpty) {
      throw Exception('Le lieu de départ est obligatoire.');
    }

    if (arrival.trim().isEmpty) {
      throw Exception('Le lieu d’arrivée est obligatoire.');
    }

    if (totalSeats <= 0) {
      throw Exception(
        'Le nombre de places doit être supérieur à zéro.',
      );
    }

    if (pricePerSeat < 0) {
      throw Exception(
        'Le prix ne peut pas être négatif.',
      );
    }

    if (!departureDateTime.isAfter(DateTime.now())) {
      throw Exception(
        'La date du trajet doit être dans le futur.',
      );
    }

    final document = _tripsCollection.doc();

    final trip = TripModel(
      id: document.id,
      driverId: driverId,

      departure: departure.trim(),
      arrival: arrival.trim(),

      departureLatitude: departureLatitude,
      departureLongitude: departureLongitude,

      arrivalLatitude: arrivalLatitude,
      arrivalLongitude: arrivalLongitude,

      departureDateTime: departureDateTime,

      pricePerSeat: pricePerSeat,

      totalSeats: totalSeats,
      availableSeats: totalSeats,

      status: TripStatus.active,

      createdAt: DateTime.now(),
    );

    await document.set(
      trip.toFirestore(),
    );

    return trip;
  }

  Stream<List<TripModel>> searchTrips({
    String? departure,
    String? arrival,
    DateTime? date,
  }) {
    Query<Map<String, dynamic>> query =
        _tripsCollection.where(
      'status',
      isEqualTo: TripStatus.active.name,
    );

    if (date != null) {
      final start = DateTime(
        date.year,
        date.month,
        date.day,
      );

      final end = start.add(
        const Duration(days: 1),
      );

      query = query
          .where(
            'departureDateTime',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(start),
          )
          .where(
            'departureDateTime',
            isLessThan:
                Timestamp.fromDate(end),
          );
    }

    return query
        .orderBy(
          'departureDateTime',
          descending: false,
        )
        .snapshots()
        .map((snapshot) {
      final trips = snapshot.docs
          .map(TripModel.fromFirestore)
          .where(
            (trip) => trip.availableSeats > 0,
          )
          .where((trip) {
        if (departure == null ||
            departure.trim().isEmpty) {
          return true;
        }

        return trip.departure
            .toLowerCase()
            .contains(
              departure.toLowerCase().trim(),
            );
      }).where((trip) {
        if (arrival == null ||
            arrival.trim().isEmpty) {
          return true;
        }

        return trip.arrival
            .toLowerCase()
            .contains(
              arrival.toLowerCase().trim(),
            );
      }).toList();

      return trips;
    });
  }

  Future<TripModel?> getTripById(
    String tripId,
  ) async {
    final document =
        await _tripsCollection.doc(tripId).get();

    if (!document.exists) {
      return null;
    }

    return TripModel.fromFirestore(document);
  }

  Future<TripModel> updateAvailableSeats({
    required String tripId,
    required int delta,
  }) async {
    final tripReference =
        _tripsCollection.doc(tripId);

    late TripModel updatedTrip;

    await firestore.runTransaction(
      (transaction) async {
        final snapshot =
            await transaction.get(tripReference);

        if (!snapshot.exists) {
          throw Exception(
            'Le trajet est introuvable.',
          );
        }

        final trip =
            TripModel.fromFirestore(snapshot);

        final newAvailableSeats =
            trip.availableSeats + delta;

        if (newAvailableSeats < 0) {
          throw Exception(
            'Pas assez de places disponibles.',
          );
        }

        if (newAvailableSeats >
            trip.totalSeats) {
          throw Exception(
            'Le nombre de places disponibles est invalide.',
          );
        }

        transaction.update(
          tripReference,
          {
            'availableSeats':
                newAvailableSeats,
          },
        );

        updatedTrip = trip.copyWith(
          availableSeats:
              newAvailableSeats,
        ) as TripModel;
      },
    );

    return updatedTrip;
  }

  Stream<List<TripModel>> getTripHistory({
    required String driverId,
  }) {
    return _tripsCollection
        .where(
          'driverId',
          isEqualTo: driverId,
        )
        .orderBy(
          'departureDateTime',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(TripModel.fromFirestore)
              .toList(),
        );
  }
}