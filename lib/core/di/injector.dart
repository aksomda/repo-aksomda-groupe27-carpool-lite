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

import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

import '../../features/vehicles/data/datasources/vehicle_remote_datasource.dart';
import '../../features/vehicles/data/repositories/vehicle_repository_impl.dart';
import '../../features/vehicles/domain/usecases/add_vehicle_usecase.dart';
import '../../features/vehicles/domain/usecases/update_vehicle_usecase.dart';
import '../../features/vehicles/domain/usecases/get_user_vehicles_usecase.dart';
import '../../features/vehicles/presentation/providers/vehicle_provider.dart';

import '../../features/trips/data/datasources/trip_remote_datasource.dart';
import '../../features/trips/data/repositories/trip_repository_impl.dart';
import '../../features/trips/domain/usecases/publish_trip_usecase.dart';
import '../../features/trips/domain/usecases/update_trip_usecase.dart';
import '../../features/trips/domain/usecases/get_trip_history_usecase.dart';
import '../../features/trips/domain/usecases/search_trips_usecase.dart';
import '../../features/trips/presentation/providers/trip_provider.dart';
import '../network/maps_api_client.dart';

import '../../features/bookings/data/datasources/booking_remote_datasource.dart';
import '../../features/bookings/data/repositories/booking_repository_impl.dart';
import '../../features/bookings/domain/usecases/cancel_booking_usecase.dart';
import '../../features/bookings/domain/usecases/confirm_booking_usecase.dart';
import '../../features/bookings/domain/usecases/get_driver_requests_usecase.dart';
import '../../features/bookings/domain/usecases/get_my_requests_usecase.dart';
import '../../features/bookings/domain/usecases/reject_booking_usecase.dart';
import '../../features/bookings/domain/usecases/request_booking_usecase.dart';
import '../../features/bookings/presentation/providers/booking_provider.dart';

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
    checkEmailVerificationUseCase: CheckEmailVerificationUseCase(
      authRepository,
    ),
    authRepository: authRepository,
  );

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
    final remoteDataSource = StatisticsRemoteDataSource(
      firestore: FirebaseFirestore.instance,
    );
    final repository = StatisticsRepositoryImpl(
      remoteDataSource: remoteDataSource,
      getDriverStatisticsUseCase: GetDriverStatistics(),
      getUniversityStatisticsUseCase: GetUniversityStatistics(),
    );
    return StatisticsProvider(repository: repository);
  }

  static ProfileProvider createProfileProvider() {
    final repository = ProfileRepositoryImpl(
      ProfileRemoteDataSource(firestore: FirebaseFirestore.instance),
    );
    return ProfileProvider(
      getProfileUseCase: GetProfileUseCase(repository),
      updateProfileUseCase: UpdateProfileUseCase(repository),
    );
  }

  static VehicleProvider createVehicleProvider() {
    final repository = VehicleRepositoryImpl(
      VehicleRemoteDataSource(firestore: FirebaseFirestore.instance),
    );
    return VehicleProvider(
      addVehicleUseCase: AddVehicleUseCase(repository),
      updateVehicleUseCase: UpdateVehicleUseCase(repository),
      getUserVehiclesUseCase: GetUserVehiclesUseCase(repository),
    );
  }

  /// Client HTTP partagé pour les appels à l'API Google Distance Matrix
  /// (une seule instance pour toute l'app).
  static final MapsApiClient mapsApiClient = MapsApiClient();

  static TripProvider createTripProvider() {
    final repository = TripRepositoryImpl(
      TripRemoteDataSource(firestore: FirebaseFirestore.instance),
    );
    return TripProvider(
      publishTripUseCase: PublishTripUseCase(repository),
      updateTripUseCase: UpdateTripUseCase(repository),
      getTripHistoryUseCase: GetTripHistoryUseCase(repository),
      searchTripsUseCase: SearchTripsUseCase(repository),
      mapsApiClient: mapsApiClient,
    );
  }

  static BookingProvider createBookingProvider() {
    final repository = BookingRepositoryImpl(
      BookingRemoteDataSource(firestore: FirebaseFirestore.instance),
    );
    return BookingProvider(
      requestBookingUseCase: RequestBookingUseCase(repository),
      confirmBookingUseCase: ConfirmBookingUseCase(repository),
      rejectBookingUseCase: RejectBookingUseCase(repository),
      cancelBookingUseCase: CancelBookingUseCase(repository),
      getDriverRequestsUseCase: GetDriverRequestsUseCase(repository),
      getMyRequestsUseCase: GetMyRequestsUseCase(repository),
    );
  }
}
