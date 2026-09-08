import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/university_model.dart';

class UniversityRemoteDataSource {
  final FirebaseFirestore firestore;

  UniversityRemoteDataSource({required this.firestore});

  Future<void> createUniversity(UniversityModel university) async {
    try {
      await firestore.collection('universities').add(university.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de l\'université : $e');
    }
  }

  Stream<List<UniversityModel>> getUniversities() {
    return firestore.collection('universities').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UniversityModel.fromFirestore(doc))
          .toList();
    });
  }
}