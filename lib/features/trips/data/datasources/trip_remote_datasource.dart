// Accès à la collection trips dans Firestore.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_timeout.dart';
import '../../../../core/firebase/firestore_retry.dart';
import '../models/trip_model.dart';

class TripRemoteDataSource {
  final FirebaseFirestore firestore;

  TripRemoteDataSource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _trips =>
      firestore.collection('trips');

  /// Génère un identifiant Firestore avant écriture, pour connaître
  /// id_trajet côté client avant le `set`.
  String newTripId() => _trips.doc().id;

  /// Écriture ponctuelle : jusqu'à 2 tentatives (1 retry).
  Future<void> createTrip(TripModel trip) {
    return FirestoreRetry.run(() async {
      try {
        await _trips
            .doc(trip.id)
            .set(trip.toFirestore())
            .timeout(kFirestoreTimeout);
      } on TimeoutException {
        throw Exception(
          "Délai dépassé en contactant Firestore. Vérifiez votre connexion "
          "et les règles de sécurité Firestore.",
        );
      } catch (e) {
        throw Exception('Erreur lors de la publication du trajet : $e');
      }
    }, maxAttempts: 2);
  }

  Future<void> updateTrip(TripModel trip) {
    return FirestoreRetry.run(() async {
      try {
        await _trips
            .doc(trip.id)
            .update(trip.toFirestore())
            .timeout(kFirestoreTimeout);
      } on TimeoutException {
        throw Exception(
          "Délai dépassé en contactant Firestore. Vérifiez votre connexion "
          "et les règles de sécurité Firestore.",
        );
      } catch (e) {
        throw Exception('Erreur lors de la modification du trajet : $e');
      }
    }, maxAttempts: 2);
  }

  /// Flux affiché en direct dans l'historique des trajets de l'utilisateur
  /// connecté, du plus récent au plus ancien.
  Stream<List<TripModel>> getTripHistory(String driverId) {
    return FirestoreRetry.runStream(() {
      return _trips
          .where('driverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => TripModel.fromFirestore(doc.id, doc.data()))
                .toList();
          });
    });
  }

  /// Flux de l'ensemble des trajets enregistrés dans Firestore, du plus
  /// récent au plus ancien : alimente le module de recherche de trajets,
  /// où un passager consulte les trajets publiés par tous les conducteurs.
  Stream<List<TripModel>> getAllTrips() {
    return FirestoreRetry.runStream(() {
      return _trips
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => TripModel.fromFirestore(doc.id, doc.data()))
                .toList();
          });
    });
  }
}
