import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_timeout.dart';
import '../models/formation_model.dart';

class FormationRemoteDataSource {
  final FirebaseFirestore firestore;

  FormationRemoteDataSource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('formations');

  Future<void> createFormation(FormationModel formation) async {
    await _timedFuture(_collection.add(formation.toFirestore()));
  }

  Future<void> updateFormation(FormationModel formation) async {
    await _timedFuture(_collection.doc(formation.id).update(formation.toFirestore()));
  }

  Future<void> softDeleteFormation(String id) async {
    await _timedFuture(_collection.doc(id).update({'isDeleted': true}));
  }

  // Le filtre "isDeleted" est appliqué côté client (voir
  // campus_remote_datasource.dart pour le détail) : une requête
  // `.where('isDeleted', isEqualTo: false)` exclurait silencieusement
  // les documents où ce champ est absent.
  Stream<List<FormationModel>> getFormations() {
    return _collection
        .snapshots()
        .timeout(kFirestoreTimeout, onTimeout: (sink) => sink.addError(_timeoutMessage))
        .map((snapshot) => snapshot.docs
            .map(FormationModel.fromFirestore)
            .where((formation) => !formation.isDeleted)
            .toList());
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
