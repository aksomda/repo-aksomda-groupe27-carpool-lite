import 'dart:typed_data';

import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile(String uid);
  Future<void> updateProfile(ProfileEntity profile);

  /// Importe [bytes] comme nouvelle photo de profil de l'utilisateur [uid]
  /// (upload Firebase Storage + mise à jour du champ `photoUrl` dans
  /// Firestore) et retourne l'URL de téléchargement obtenue.
  Future<String> updatePhoto(String uid, Uint8List bytes);
}