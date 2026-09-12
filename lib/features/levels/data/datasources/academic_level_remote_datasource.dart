import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_timeout.dart';
import '../models/academic_level_model.dart';

class AcademicLevelRemoteDataSource {
  final FirebaseFirestore firestore;

  AcademicLevelRemoteDataSource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('academic_levels');

  Future<void> createLevel(AcademicLevelModel level) async {
    await _timedFuture(_collection.add(level.toFirestore()));
  }

  Future<void> updateLevel(AcademicLevelModel level) async {
    await _timedFuture(_collection.doc(level.id).update(level.toFirestore()));
  }

  Future<void> softDeleteLevel(String id) async {
    await _timedFuture(_collection.doc(id).update({'isDeleted': true}));
  }

  Stream<List<AcademicLevelModel>> getLevels() {
    return _collection
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .timeout(kFirestoreTimeout, onTimeout: (sink) => sink.addError(_timeoutMessage))
        .map((snapshot) => snapshot.docs.map(AcademicLevelModel.fromFirestore).toList());
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
