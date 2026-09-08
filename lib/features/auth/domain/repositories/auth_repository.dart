import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Inscription d'un nouvel étudiant
  Future<UserEntity> signUp({
    required String name,
    required String email,
    required String password,
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
}