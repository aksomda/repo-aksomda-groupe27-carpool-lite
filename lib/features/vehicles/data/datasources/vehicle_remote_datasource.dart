// Accès à la collection vehicles dans Firestore.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_timeout.dart';
import '../../../../core/firebase/firestore_retry.dart';
import '../models/vehicle_model.dart';

class VehicleRemoteDataSource {
  final FirebaseFirestore firestore;

  VehicleRemoteDataSource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _vehicles =>
      firestore.collection('vehicles');

  /// Génère un identifiant Firestore avant écriture, pour connaître
  /// id_vehicule côté client avant le `set`.
  String newVehicleId() => _vehicles.doc().id;

  /// Écriture ponctuelle : jusqu'à 2 tentatives (1 retry), pour ne pas trop
  /// faire attendre l'utilisateur sur un bouton "Enregistrer".
  Future<void> createVehicle(VehicleModel vehicle) {
    return FirestoreRetry.run(() async {
      try {
        await _vehicles
            .doc(vehicle.id)
            .set(vehicle.toFirestore())
            .timeout(kFirestoreTimeout);
      } on TimeoutException {
        throw Exception(
          "Délai dépassé en contactant Firestore. Vérifiez votre connexion "
          "et les règles de sécurité Firestore.",
        );
      } catch (e) {
        throw Exception("Erreur lors de la sauvegarde du véhicule : $e");
      }
    }, maxAttempts: 2);
  }

  Future<void> updateVehicle(VehicleModel vehicle) {
    return FirestoreRetry.run(() async {
      try {
        await _vehicles
            .doc(vehicle.id)
            .update(vehicle.toFirestore())
            .timeout(kFirestoreTimeout);
      } on TimeoutException {
        throw Exception(
          "Délai dépassé en contactant Firestore. Vérifiez votre connexion "
          "et les règles de sécurité Firestore.",
        );
      } catch (e) {
        throw Exception("Erreur lors de la modification du véhicule : $e");
      }
    }, maxAttempts: 2);
  }

  /// Flux affiché en direct dans la liste "Mes véhicules" : on retente plus
  /// longtemps en arrière-plan avant d'abandonner.
  Stream<List<VehicleModel>> getUserVehicles(String ownerId) {
    return FirestoreRetry.runStream(() {
      return _vehicles
          .where('ownerId', isEqualTo: ownerId)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => VehicleModel.fromFirestore(doc.id, doc.data()))
                .toList();
          });
    });
  }
}
