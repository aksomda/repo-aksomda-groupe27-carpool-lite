import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_timeout.dart';
import '../../../../core/firebase/firestore_retry.dart';
import '../models/university_model.dart';

class UniversityRemoteDataSource {
  final FirebaseFirestore firestore;

  UniversityRemoteDataSource({required this.firestore});

  /// Écriture ponctuelle : jusqu'à 2 tentatives (1 retry) pour ne pas trop
  /// faire attendre l'utilisateur sur un bouton "Enregistrer".
  Future<void> createUniversity(UniversityModel university) {
    return FirestoreRetry.run(() async {
      try {
        await firestore
            .collection('universities')
            .add(university.toFirestore())
            .timeout(kFirestoreTimeout);
      } on TimeoutException {
        throw Exception(
          "Délai dépassé en contactant Firestore. Vérifiez que la base "
          "Firestore a bien été créée pour votre projet Firebase et que les "
          "règles de sécurité autorisent l'écriture (voir DEPANNAGE_FIRESTORE.md).",
        );
      } catch (e) {
        throw Exception("Erreur lors de la sauvegarde de l'université : $e");
      }
    }, maxAttempts: 2);
  }

  /// Écriture ponctuelle : jusqu'à 2 tentatives (1 retry), comme
  /// [createUniversity].
  Future<void> updateUniversity(UniversityModel university) {
    return FirestoreRetry.run(() async {
      try {
        await firestore
            .collection('universities')
            .doc(university.id)
            .update(university.toFirestore())
            .timeout(kFirestoreTimeout);
      } on TimeoutException {
        throw Exception(
          "Délai dépassé en contactant Firestore. Vérifiez que la base "
          "Firestore a bien été créée pour votre projet Firebase et que les "
          "règles de sécurité autorisent l'écriture (voir DEPANNAGE_FIRESTORE.md).",
        );
      } catch (e) {
        throw Exception("Erreur lors de la modification de l'université : $e");
      }
    }, maxAttempts: 2);
  }

  /// Flux affiché en direct dans la liste : on retente plus longtemps en
  /// arrière-plan (jusqu'à 5 tentatives) avant d'abandonner, puisque
  /// l'utilisateur n'a pas d'action bloquée en attente.
  Stream<List<UniversityModel>> getUniversities() {
    return FirestoreRetry.runStream(() {
      return firestore
          .collection('universities')
          .snapshots()
          .timeout(
            kFirestoreTimeout,
            onTimeout: (sink) => sink.addError(
              "Délai dépassé en contactant Firestore. Vérifiez que la base "
              "Firestore a bien été créée pour votre projet Firebase et que "
              "les règles de sécurité autorisent la lecture "
              "(voir DEPANNAGE_FIRESTORE.md).",
            ),
          )
          .map((snapshot) {
            return snapshot.docs.map((doc) => UniversityModel.fromFirestore(doc)).toList();
          });
    });
  }
}
