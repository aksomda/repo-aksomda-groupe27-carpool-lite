import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/booking_entity.dart';
import '../models/booking_model.dart';
import '../models/ride_request_model.dart';

class BookingRemoteDataSource {
  final FirebaseFirestore firestore;

  BookingRemoteDataSource({
    required this.firestore,
  });

  CollectionReference<Map<String, dynamic>>
      _bookingsCollection(
    String tripId,
  ) {
    return firestore
        .collection('trips')
        .doc(tripId)
        .collection('bookings');
  }

  CollectionReference<Map<String, dynamic>>
      get _requestsCollection {
    return firestore.collection('rideRequests');
  }

  DocumentReference<Map<String, dynamic>>
      _tripReference(String tripId) {
    return firestore
        .collection('trips')
        .doc(tripId);
  }

  // ============================================================
  // DEMANDER UNE RÉSERVATION
  // ============================================================

  Future<RideRequestModel> requestBooking({
    required String tripId,
    required String passengerId,
    required String driverId,
    required int numberOfSeats,
    required double totalPrice,
  }) async {
    if (numberOfSeats <= 0) {
      throw Exception(
        'Le nombre de places doit être supérieur à zéro.',
      );
    }

    final requestReference =
        _requestsCollection.doc();

    late RideRequestModel request;

    await firestore.runTransaction(
      (transaction) async {
        final tripReference =
            _tripReference(tripId);

        final tripSnapshot =
            await transaction.get(tripReference);

        if (!tripSnapshot.exists) {
          throw Exception(
            'Le trajet est introuvable.',
          );
        }

        final tripData =
            tripSnapshot.data()!;

        final availableSeats =
            (tripData['availableSeats'] as num?)
                    ?.toInt() ??
                0;

        if (availableSeats < numberOfSeats) {
          throw Exception(
            'Il ne reste que $availableSeats place(s) disponible(s).',
          );
        }

        // NB : les places ne sont PAS déduites ici. Une demande "en attente"
        // ne réserve rien ; le trajet reste consultable/disponible pour
        // d'autres passagers tant que le conducteur n'a pas accepté (voir
        // confirmBooking, qui fait la déduction réelle de façon atomique).
        request = RideRequestModel(
          id: requestReference.id,
          tripId: tripId,
          passengerId: passengerId,
          driverId: driverId,
          numberOfSeats: numberOfSeats,
          totalPrice: totalPrice,
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        transaction.set(
          requestReference,
          request.toFirestore(),
        );
      },
    );

    return request;
  }

  // ============================================================
  // ACCEPTER LA DEMANDE
  // ============================================================

  Future<BookingModel> confirmBooking({
    required String requestId,
  }) async {
    final requestReference =
        _requestsCollection.doc(requestId);

    late BookingModel booking;

    await firestore.runTransaction(
      (transaction) async {
        final requestSnapshot =
            await transaction.get(requestReference);

        if (!requestSnapshot.exists) {
          throw Exception(
            'La demande est introuvable.',
          );
        }

        final request =
            RideRequestModel.fromFirestore(
          requestSnapshot,
        );

        if (request.status != BookingStatus.pending) {
          throw Exception(
            'Cette demande a déjà été traitée.',
          );
        }

        // La déduction des places disponibles se fait ICI, au moment de
        // l'acceptation, et non à la création de la demande. On relit le
        // trajet dans la même transaction pour garantir la cohérence :
        // si plusieurs demandes concurrentes dépassent la capacité
        // restante, seules celles pour lesquelles il reste assez de places
        // au moment de l'acceptation peuvent être confirmées.
        final tripReference =
            _tripReference(request.tripId);

        final tripSnapshot =
            await transaction.get(tripReference);

        if (!tripSnapshot.exists) {
          throw Exception(
            'Le trajet est introuvable.',
          );
        }

        final tripData = tripSnapshot.data()!;

        final availableSeats =
            (tripData['availableSeats'] as num?)
                    ?.toInt() ??
                0;

        if (availableSeats < request.numberOfSeats) {
          throw Exception(
            'Il ne reste que $availableSeats place(s) disponible(s) : '
            'impossible d’accepter cette demande de '
            '${request.numberOfSeats} place(s).',
          );
        }

        transaction.update(
          tripReference,
          {
            'availableSeats':
                availableSeats - request.numberOfSeats,
          },
        );

        final bookingReference =
            _bookingsCollection(
          request.tripId,
        ).doc();

        booking = BookingModel(
          id: bookingReference.id,
          tripId: request.tripId,
          passengerId: request.passengerId,
          driverId: request.driverId,
          numberOfSeats:
              request.numberOfSeats,
          totalPrice:
              request.totalPrice,
          status: BookingStatus.confirmed,
          reservationDate: DateTime.now(),
        );

        transaction.set(
          bookingReference,
          booking.toFirestore(),
        );

        transaction.update(
          requestReference,
          {
            'status':
                BookingStatus.confirmed.name,
          },
        );
      },
    );

    return booking;
  }

  // ============================================================
  // REFUSER UNE DEMANDE
  // ============================================================

  Future<void> rejectBookingRequest({
    required String requestId,
  }) async {
    final requestReference =
        _requestsCollection.doc(requestId);

    await firestore.runTransaction(
      (transaction) async {
        final requestSnapshot =
            await transaction.get(
          requestReference,
        );

        if (!requestSnapshot.exists) {
          throw Exception(
            'La demande est introuvable.',
          );
        }

        final request =
            RideRequestModel.fromFirestore(
          requestSnapshot,
        );

        if (request.status != BookingStatus.pending) {
          throw Exception(
            'Cette demande a déjà été traitée.',
          );
        }

        // Un rejet ne modifie jamais le nombre de places disponibles du
        // trajet : la demande "en attente" n'en avait déduit aucune (voir
        // requestBooking), il n'y a donc rien à restituer ici.
        transaction.update(
          requestReference,
          {
            'status':
                BookingStatus.cancelled.name,
          },
        );
      },
    );
  }

  // ============================================================
  // ANNULER UNE RÉSERVATION CONFIRMÉE
  // ============================================================

  Future<void> cancelBooking({
    required String tripId,
    required String bookingId,
  }) async {
    final bookingReference =
        _bookingsCollection(
      tripId,
    ).doc(bookingId);

    await firestore.runTransaction(
      (transaction) async {
        final bookingSnapshot =
            await transaction.get(
          bookingReference,
        );

        if (!bookingSnapshot.exists) {
          throw Exception(
            'La réservation est introuvable.',
          );
        }

        final booking =
            BookingModel.fromFirestore(
          bookingSnapshot,
        );

        if (booking.status ==
            BookingStatus.cancelled) {
          throw Exception(
            'Cette réservation est déjà annulée.',
          );
        }

        final tripReference =
            _tripReference(tripId);

        final tripSnapshot =
            await transaction.get(
          tripReference,
        );

        if (!tripSnapshot.exists) {
          throw Exception(
            'Le trajet est introuvable.',
          );
        }

        final tripData =
            tripSnapshot.data()!;

        final availableSeats =
            (tripData['availableSeats'] as num?)
                    ?.toInt() ??
                0;

        final totalSeats =
            (tripData['totalSeats'] as num?)
                    ?.toInt() ??
                0;

        final newAvailableSeats =
            availableSeats +
                booking.numberOfSeats;

        if (newAvailableSeats > totalSeats) {
          throw Exception(
            'Impossible de restituer les places.',
          );
        }

        // Restituer les places.
        transaction.update(
          tripReference,
          {
            'availableSeats':
                newAvailableSeats,
          },
        );

        // Annuler la réservation.
        transaction.update(
          bookingReference,
          {
            'status':
                BookingStatus.cancelled.name,
          },
        );
      },
    );
  }

  // ============================================================
  // RÉSERVATIONS DU PASSAGER
  // ============================================================

  Stream<List<BookingModel>> getUserBookings({
    required String passengerId,
  }) {
    return firestore
        .collectionGroup('bookings')
        .where(
          'passengerId',
          isEqualTo: passengerId,
        )
        .orderBy(
          'reservationDate',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  BookingModel.fromFirestore,
                )
                .toList();
          },
        );
  }

  // ============================================================
  // DEMANDES DU CONDUCTEUR
  // ============================================================

  Stream<List<RideRequestModel>>
      getDriverRequests({
    required String driverId,
  }) {
    return _requestsCollection
        .where(
          'driverId',
          isEqualTo: driverId,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  RideRequestModel.fromFirestore,
                )
                .toList();
          },
        );
  }

  // ============================================================
  // DEMANDES DU PASSAGER (pour suivi avant acceptation)
  // ============================================================

  Stream<List<RideRequestModel>>
      getUserRequests({
    required String passengerId,
  }) {
    return _requestsCollection
        .where(
          'passengerId',
          isEqualTo: passengerId,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  RideRequestModel.fromFirestore,
                )
                .toList();
          },
        );
  }
}