import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_timeout.dart';
import '../../../../core/firebase/firestore_retry.dart';
import '../models/campus_model.dart';

class CampusRemoteDataSource {
  final FirebaseFirestore firestore;

  CampusRemoteDataSource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('campus');

  // Écritures ponctuelles : 2 tentatives max (1 retry) pour rester réactif
  // sur les actions utilisateur (création/édition/suppression).
  Future<void> createCampus(CampusModel campus) {
    return FirestoreRetry.run(
      () => _timedFuture(_collection.add(campus.toFirestore())),
      maxAttempts: 2,
    );
  }

  Future<void> updateCampus(CampusModel campus) {
    return FirestoreRetry.run(
      () => _timedFuture(_collection.doc(campus.id).update(campus.toFirestore())),
      maxAttempts: 2,
    );
  }

  /// Suppression logique : on ne retire pas le document, on le marque
  /// comme supprimé pour qu'il disparaisse des listes actives.
  Future<void> softDeleteCampus(String id) {
    return FirestoreRetry.run(
      () => _timedFuture(_collection.doc(id).update({'isDeleted': true})),
      maxAttempts: 2,
    );
  }

  // Flux affiché en direct : on retente plus longtemps en arrière-plan
  // (5 tentatives) avant d'abandonner.
  Stream<List<CampusModel>> getCampuses() {
    return FirestoreRetry.runStream(() {
      return _collection
          .where('isDeleted', isEqualTo: false)
          .snapshots()
          .timeout(kFirestoreTimeout, onTimeout: (sink) => sink.addError(_timeoutMessage))
          .map((snapshot) => snapshot.docs.map(CampusModel.fromFirestore).toList());
    });
  }

  Future<T> _timedFuture<T>(Future<T> future) async {
    try {
      return await future.timeout(kFirestoreTimeout);
    } on TimeoutException {
      throw Exception(_timeoutMessage);
    }
  }
}

const String _timeoutMessage =
    "Délai dépassé en contactant Firestore. Vérifiez que la base Firestore "
    "a bien été créée pour votre projet Firebase et que les règles de "
    "sécurité autorisent l'accès (voir DEPANNAGE_FIRESTORE.md).";
