import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSource({
    required this.firebaseAuth,
    required this.firestore,
  });

  /// Inscription d'un nouvel utilisateur
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required Sex sex,
    String? universityId,
    String? campusId,
  }) async {
    try {
      // 1. Création du compte dans Firebase Authentication
      final UserCredential credential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception(
          'Impossible de créer le compte utilisateur.',
        );
      }

      // 2. Création du profil utilisateur
      final UserModel user = UserModel(
        uid: firebaseUser.uid,
        email: email.trim(),
        name: name.trim(),
        phone: phone.trim(),
        sex: sex,
        universityId: universityId,
        campusId: campusId,
        isVerified: false,
        isActive: false,
        role: 'student',
      );

      // 3. Enregistrement du profil dans Firestore
      await firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set({
        ...user.toFirestore(),
        'emailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  /// Connexion d'un utilisateur existant
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Connexion avec Firebase Authentication
      final UserCredential credential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception(
          'Impossible de récupérer l’utilisateur connecté.',
        );
      }

      // 2. Récupération du profil depuis Firestore
      final DocumentSnapshot<Map<String, dynamic>> document =
          await firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .get();

      if (!document.exists) {
        throw Exception(
          'Le profil utilisateur est introuvable.',
        );
      }
      final user = UserModel.fromFirestore(document);
      if (!user.isActive) {
        await firebaseAuth.signOut();
        throw Exception('Votre compte est en attente d’activation par un administrateur.');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  /// Récupération de l'utilisateur actuellement connecté
  Future<UserModel?> getCurrentUser() async {
    final User? firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    final DocumentSnapshot<Map<String, dynamic>> document =
        await firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

    if (!document.exists) {
      return null;
    }

    return UserModel.fromFirestore(document);
  }

  /// Vérifie qu'un étudiant est bien enregistré
  Future<bool> verifyStudent({
    required String uid,
    required String studentId,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> document =
          await firestore
              .collection('students')
              .doc(studentId)
              .get();

      if (!document.exists) {
        return false;
      }

      final data = document.data();

      if (data == null) {
        return false;
      }

      final String? studentUid = data['uid'] as String?;

      if (studentUid != null && studentUid != uid) {
        return false;
      }

      await firestore
          .collection('users')
          .doc(uid)
          .update({
        'isVerified': true,
        'studentId': studentId,
      });

      return true;
    } catch (e) {
      throw Exception(
        'Erreur lors de la vérification de l’étudiant : $e',
      );
    }
  }

  /// Envoie le lien de vérification officiel de Firebase Authentication.
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('Aucun utilisateur connecté.');
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  /// Actualise l'utilisateur après l'ouverture du lien reçu par e-mail.
  Future<bool> checkEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return false;

      await user.reload();
      final refreshedUser = firebaseAuth.currentUser;
      if (refreshedUser == null || !refreshedUser.emailVerified) return false;

      await firestore.collection('users').doc(refreshedUser.uid).update({
        'emailVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  /// Messages d'erreur Firebase Authentication
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée.';

      case 'invalid-email':
        return 'L’adresse email est invalide.';

      case 'weak-password':
        return 'Le mot de passe est trop faible.';

      case 'user-not-found':
        return 'Aucun compte ne correspond à cette adresse email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';

      case 'user-disabled':
        return 'Ce compte a été désactivé.';

      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard.';

      case 'network-request-failed':
        return 'Problème de connexion Internet.';

      case 'operation-not-allowed':
      case 'configuration-not-found':
        return 'La connexion par email et mot de passe n’est pas encore '
            'activée dans Firebase Authentication pour le projet carpoollite.';

      case 'app-not-authorized':
      case 'invalid-api-key':
      case 'api-key-not-valid':
        return 'La configuration Firebase de l’application est invalide ou '
            'n’est pas autorisée pour ce projet.';

      default:
        // Le code Firebase aide à diagnostiquer une configuration incomplète
        // sans afficher de données sensibles à l’utilisateur.
        return 'Erreur d’authentification Firebase (${e.code}).';
    }
  }
}
