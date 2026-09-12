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

import '../../features/reviews/data/datasources/review_remote_datasource.dart';
import '../../features/reviews/data/repositories/review_repository_impl.dart';
import '../../features/reviews/domain/usecases/create_review.dart';
import '../../features/reviews/domain/usecases/get_reviews_for_user_usecase.dart';
import '../../features/reviews/presentation/providers/review_provider.dart';

import '../../features/statistics/data/datasources/statistics_remote_datasource.dart';
import '../../features/statistics/data/repositories/statistics_repository_impl.dart';
import '../../features/statistics/domain/usecases/get_driver_statistics.dart';
import '../../features/statistics/domain/usecases/get_university_statistics.dart';
import '../../features/statistics/presentation/providers/statistics_provider.dart';


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

  static ReviewProvider createReviewProvider() {
    final repository = ReviewRepositoryImpl(
      remoteDataSource: ReviewRemoteDataSource(FirebaseFirestore.instance),
    );
    return ReviewProvider(
      createReviewUseCase: CreateReview(repository),
      getReviewsForUserUseCase: GetReviewsForUserUseCase(repository),
    );
  }

  static StatisticsProvider createStatisticsProvider() {
    final remoteDataSource =
        StatisticsRemoteDataSource(firestore: FirebaseFirestore.instance);
    final repository = StatisticsRepositoryImpl(
      remoteDataSource: remoteDataSource,
      getDriverStatisticsUseCase: GetDriverStatistics(),
      getUniversityStatisticsUseCase: GetUniversityStatistics(),
    );
    return StatisticsProvider(repository: repository);
  }
}
