import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/formation_model.dart';

class FormationRemoteDataSource {
  final FirebaseFirestore firestore;

  FormationRemoteDataSource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('formations');

  Future<void> createFormation(FormationModel formation) async {
    await _collection.add(formation.toFirestore());
  }

  Future<void> updateFormation(FormationModel formation) async {
    await _collection.doc(formation.id).update(formation.toFirestore());
  }

  Future<void> softDeleteFormation(String id) async {
    await _collection.doc(id).update({'isDeleted': true});
  }

  Stream<List<FormationModel>> getFormations() {
    return _collection
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(FormationModel.fromFirestore).toList());
  }
}
