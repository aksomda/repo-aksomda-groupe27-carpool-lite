import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/university_model.dart';

class UniversityRemoteDataSource {
  final FirebaseFirestore firestore;

  UniversityRemoteDataSource({required this.firestore});

  // 1. Sauvegarder / Créer une université dans Firestore
  Future<void> createUniversity(UniversityModel university) async {
    try {
      // Si vous voulez que Firestore génère un ID automatique :
      await firestore.collection('universities').add(university.toFirestore());

      /* Si vous préférez utiliser l'ID de l'entité (ex: code postal ou slug) :
      await firestore
          .collection('universities')
          .doc(university.id)
          .set(university.toFirestore());
      */
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de l\'université : $e');
    }
  }

  // 2. Récupérer la liste de toutes les universités (en temps réel avec Stream)
  Stream<List<UniversityModel>> getUniversities() {
    return firestore.collection('universities').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UniversityModel.fromFirestore(doc))
          .toList();
    });
  }
}
