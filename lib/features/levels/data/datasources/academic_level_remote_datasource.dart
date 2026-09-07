import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/academic_level_model.dart';

class AcademicLevelRemoteDataSource {
  final FirebaseFirestore firestore;

  AcademicLevelRemoteDataSource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('academic_levels');

  Future<void> createLevel(AcademicLevelModel level) async {
    await _collection.add(level.toFirestore());
  }

  Future<void> updateLevel(AcademicLevelModel level) async {
    await _collection.doc(level.id).update(level.toFirestore());
  }

  Future<void> softDeleteLevel(String id) async {
    await _collection.doc(id).update({'isDeleted': true});
  }

  Stream<List<AcademicLevelModel>> getLevels() {
    return _collection
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(AcademicLevelModel.fromFirestore).toList());
  }
}
