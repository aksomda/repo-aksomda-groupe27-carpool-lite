import 'package:flutter/foundation.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/verify_student_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final SignInUserCase signInUserCase;
  final SignUpUserCase signUpUserCase;
  final VerifyStudentUseCase verifyStudentUseCase;
  final AuthRepository authRepository;

  AuthProvider({
    required this.signInUserCase,
    required this.signUpUserCase,
    required this.verifyStudentUseCase,
    required this.authRepository,
  });

  UserEntity? _user;

  bool _isLoading = false;
  String? _errorMessage;

  UserEntity? get user => _user;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _user != null;

  /// Connexion
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await signInUserCase(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Inscription
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String sex,
    String? universityId,
    String? campusId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await signUpUserCase(
        name: name,
        email: email,
        password: password,
        phone: phone,
        sex: sex,
        universityId: universityId,
        campusId: campusId,
      );

      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Vérification étudiant
  Future<bool> verifyStudent({
    required String studentId,
  }) async {
    if (_user == null) {
      _errorMessage = 'Aucun utilisateur connecté.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final bool verified = await verifyStudentUseCase(
        uid: _user!.uid,
        studentId: studentId,
      );

      if (verified) {
        _user = UserEntity(
          uid: _user!.uid,
          email: _user!.email,
          name: _user!.name,
          phone: _user!.phone,
          sex: _user!.sex,
          universityId: _user!.universityId,
          campusId: _user!.campusId,
          isVerified: true,
          role: _user!.role,
        );
      }

      return verified;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await authRepository.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Récupération de la session existante
  Future<void> checkCurrentUser() async {
    _setLoading(true);
    _clearError();

    try {
      _user = await authRepository.getCurrentUser();
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _cleanErrorMessage(Object error) {
    final String message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }
}