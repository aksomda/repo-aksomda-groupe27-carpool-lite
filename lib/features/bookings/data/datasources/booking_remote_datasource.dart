// Accès à la collection rideRequests dans Firestore.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_timeout.dart';
import '../../../../core/firebase/firestore_retry.dart';
import '../../domain/entities/ride_request_entity.dart';
import '../models/ride_request_model.dart';

class BookingRemoteDataSource {
  final FirebaseFirestore firestore;

  BookingRemoteDataSource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _requests =>
      firestore.collection('rideRequests');

  /// Génère un identifiant Firestore avant écriture, pour connaître
  /// id_demande côté client avant le `set`.
  String newRequestId() => _requests.doc().id;

  /// Écriture ponctuelle : jusqu'à 2 tentatives (1 retry).
  Future<void> createRequest(RideRequestModel request) {
    return FirestoreRetry.run(() async {
      try {
        await _requests
            .doc(request.id)
            .set(request.toFirestore())
            .timeout(kFirestoreTimeout);
      } on TimeoutException {
        throw Exception(
          "Délai dépassé en contactant Firestore. Vérifiez votre connexion "
          "et les règles de sécurité Firestore.",
        );
      } catch (e) {
        throw Exception('Erreur lors de la création de la demande : $e');
      }
    }, maxAttempts: 2);
  }

  Future<void> updateStatus(String requestId, RideRequestStatus statut) {
    return FirestoreRetry.run(() async {
      try {
        await _requests
            .doc(requestId)
            .update({'statut': statut.value}).timeout(kFirestoreTimeout);
      } on TimeoutException {
        throw Exception(
          "Délai dépassé en contactant Firestore. Vérifiez votre connexion "
          "et les règles de sécurité Firestore.",
        );
      } catch (e) {
        throw Exception('Erreur lors de la mise à jour de la demande : $e');
      }
    }, maxAttempts: 2);
  }

  /// Flux des demandes reçues par [driverId] sur ses trajets, du plus
  /// récent au plus ancien.
  Stream<List<RideRequestModel>> getDriverRequests(String driverId) {
    return FirestoreRetry.runStream(() {
      return _requests
          .where('driverId', isEqualTo: driverId)
          .orderBy('dateDemande', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => RideRequestModel.fromFirestore(doc.id, doc.data()))
                .toList();
          });
    });
  }

  /// Flux des demandes envoyées par [passengerId], du plus récent au plus
  /// ancien.
  Stream<List<RideRequestModel>> getMyRequests(String passengerId) {
    return FirestoreRetry.runStream(() {
      return _requests
          .where('passengerId', isEqualTo: passengerId)
          .orderBy('dateDemande', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => RideRequestModel.fromFirestore(doc.id, doc.data()))
                .toList();
          });
    });
  }
}
