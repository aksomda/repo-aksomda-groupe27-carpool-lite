import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Inscription d'un nouvel étudiant
  Future<UserEntity> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required Sex sex,
    String? universityId,
    String? campusId,
  });

  /// Connexion d'un étudiant
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  /// Déconnexion
  Future<void> signOut();

  /// Récupère l'utilisateur actuellement connecté
  Future<UserEntity?> getCurrentUser();

  /// Vérifie les informations de l'étudiant
  Future<bool> verifyStudent({
    required String uid,
    required String studentId,
  });

  /// Envoie le lien de vérification natif de Firebase Authentication.
  Future<void> sendEmailVerification();

  /// Recharge l'utilisateur Firebase et retourne son état de vérification.
  Future<bool> checkEmailVerification();
}
