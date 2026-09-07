import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ufr_model.dart';

class UfrRemoteDataSource {
  final FirebaseFirestore firestore;

  UfrRemoteDataSource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('ufrs');

  Future<void> createUfr(UfrModel ufr) async {
    await _collection.add(ufr.toFirestore());
  }

  Future<void> updateUfr(UfrModel ufr) async {
    await _collection.doc(ufr.id).update(ufr.toFirestore());
  }

  /// Suppression logique : on ne retire pas le document, on le marque
  /// comme supprimé pour qu'il disparaisse des listes actives.
  Future<void> softDeleteUfr(String id) async {
    await _collection.doc(id).update({'isDeleted': true});
  }

  Stream<List<UfrModel>> getUfrs() {
    return _collection
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(UfrModel.fromFirestore).toList());
  }
}
