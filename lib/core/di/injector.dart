import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/verify_student_usecase.dart';
import '../../features/auth/domain/usecases/check_email_verification_usecase.dart';
import '../../features/auth/domain/usecases/send_email_verification_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

import '../../features/universities/data/datasources/university_remote_datasource.dart';
import '../../features/universities/data/repositories/university_repository_impl.dart';
import '../../features/universities/domain/usecases/get_universities_usecase.dart';
import '../../features/universities/domain/usecases/add_university_usecase.dart';
import '../../features/universities/presentation/providers/university_provider.dart';


/// Point unique de câblage manuel des dépendances (pas d'injection de code
/// généré : on construit ici, une seule fois, les datasources → repository
/// → usecases → providers, à partir des instances Firebase déjà
/// initialisées dans main.dart).
class Injector {
  Injector._();

  static final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSource(
      firebaseAuth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    ),
  );

  /// Instance unique partagée par tout l'arbre de routes : la session de
  /// l'utilisateur (connecté ou non) doit rester la même d'un écran à
  /// l'autre.
  static final AuthProvider authProvider = AuthProvider(
    signInUserCase: SignInUserCase(authRepository),
    signUpUserCase: SignUpUserCase(authRepository),
    verifyStudentUseCase: VerifyStudentUseCase(authRepository),
    sendEmailVerificationUseCase: SendEmailVerificationUseCase(authRepository),
    checkEmailVerificationUseCase: CheckEmailVerificationUseCase(authRepository),
    authRepository: authRepository,
  );

  static UniversityProvider createUniversityProvider() {
    final repository = UniversityRepositoryImpl(
      UniversityRemoteDataSource(firestore: FirebaseFirestore.instance),
    );
    return UniversityProvider(
      getUniversitiesUseCase: GetUniversitiesUseCase(repository),
      addUniversityUseCase: AddUniversityUseCase(repository),
    );
  }
}
