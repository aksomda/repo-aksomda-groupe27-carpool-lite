import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_model.dart';

class ProfileRemoteDataSource {
  final FirebaseFirestore firestore;

  ProfileRemoteDataSource({required this.firestore});

  /// Récupère les informations d'un utilisateur à partir de son identifiant
  /// (document Firestore `users/{userId}`).
  Future<ProfileModel> getUserById(String userId) async {
    final doc = await firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('Utilisateur introuvable.');
    }
    return ProfileModel.fromFirestore(doc);
  }

  Future<void> updateProfile(ProfileModel profile) async {
    await firestore
        .collection('users')
        .doc(profile.uid)
        .update(profile.toFirestoreUpdate());
  }
}