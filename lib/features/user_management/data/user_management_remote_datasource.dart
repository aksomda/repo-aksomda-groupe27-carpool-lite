import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/data/models/user_model.dart';

class UserManagementRemoteDataSource {
  final FirebaseFirestore firestore;

  UserManagementRemoteDataSource({required this.firestore});

  Stream<List<UserModel>> getUsers() {
    return firestore.collection('users').snapshots().map(
          (snapshot) => snapshot.docs
              .map(UserModel.fromFirestore)
              .toList()
            ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
        );
  }

  Future<void> updateUser({
    required String uid,
    required bool isActive,
    required String role,
  }) {
    return firestore.collection('users').doc(uid).update({
      'isActive': isActive,
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
