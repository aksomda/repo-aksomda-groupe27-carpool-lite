import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_model.dart';

class ProfileRemoteDataSource {
  final FirebaseFirestore firestore;

  ProfileRemoteDataSource({required this.firestore});

  Future<ProfileModel> getProfile(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('Profil introuvable.');
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