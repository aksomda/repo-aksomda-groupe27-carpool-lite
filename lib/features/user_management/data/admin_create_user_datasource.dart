// Création d'un compte utilisateur par un administrateur, depuis l'écran
// "Gestion des utilisateurs".
//
// Piège classique avec Firebase Auth côté client : appeler
// createUserWithEmailAndPassword() sur l'instance FirebaseAuth "normale"
// connecte automatiquement l'application avec ce NOUVEAU compte, ce qui
// déconnecterait l'administrateur en train de créer l'utilisateur. Pour
// l'éviter, on crée le compte via une application Firebase secondaire et
// temporaire, indépendante de la session de l'administrateur, puis on la
// supprime aussitôt après avoir écrit le profil dans Firestore (instance
// Firestore principale).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../auth/data/models/user_model.dart';
import '../../auth/domain/entities/user_entity.dart';

class AdminCreateUserDataSource {
  final FirebaseFirestore firestore;

  AdminCreateUserDataSource({required this.firestore});

  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required Sex sex,
    required String role,
    required bool isActive,
    String? universityId,
    String? campusId,
  }) async {
    final secondaryApp = await Firebase.initializeApp(
      name: 'adminUserCreation-${DateTime.now().microsecondsSinceEpoch}',
      options: Firebase.app().options,
    );

    try {
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Impossible de créer le compte utilisateur.');
      }

      final user = UserModel(
        uid: firebaseUser.uid,
        email: email.trim(),
        name: name.trim(),
        phone: phone.trim(),
        sex: sex,
        universityId: universityId,
        campusId: campusId,
        // Compte créé directement par un administrateur : on considère
        // l'e-mail vérifié et le compte utilisable immédiatement, sans
        // repasser par le circuit d'auto-inscription (OTP, vérification
        // étudiant...).
        isVerified: true,
        isActive: isActive,
        role: role,
      );

      await firestore.collection('users').doc(firebaseUser.uid).set({
        ...user.toFirestore(),
        'emailVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    } finally {
      // Ferme puis supprime l'app secondaire : elle n'a servi qu'à créer
      // le compte, elle ne doit laisser aucune session active.
      await secondaryApp.delete();
    }
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée.';
      case 'invalid-email':
        return 'L’adresse email est invalide.';
      case 'weak-password':
        return 'Le mot de passe est trop faible (6 caractères minimum).';
      default:
        return 'Erreur d’authentification Firebase (${e.code}).';
    }
  }
}
