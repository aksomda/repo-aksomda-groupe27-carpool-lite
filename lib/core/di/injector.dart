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

import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

import '../../features/bookings/data/datasources/booking_remote_datasource.dart';
import '../../features/bookings/data/repositories/booking_repository_impl.dart';
import '../../features/bookings/domain/repositories/booking_repository.dart';
import '../../features/bookings/domain/usecases/request_booking_usecase.dart';
import '../../features/bookings/domain/usecases/confirm_booking_usecase.dart';
import '../../features/bookings/domain/usecases/reject_booking_request_usecase.dart';
import '../../features/bookings/domain/usecases/cancel_booking_usecase.dart';
import '../../features/bookings/presentation/providers/booking_provider.dart';

import '../../features/trips/data/datasources/trip_remote_datasource.dart';
import '../../features/trips/data/repositories/trip_repository_impl.dart';
import '../../features/trips/domain/usecases/get_trip_history_usecase.dart';
import '../../features/trips/domain/usecases/publish_trip_usecase.dart';
import '../../features/trips/domain/usecases/search_trips_usecase.dart';
import '../../features/trips/presentation/providers/trip_provider.dart';

import '../../features/vehicles/data/datasources/vehicle_remote_datasource.dart';
import '../../features/vehicles/data/repositories/vehicle_repository_impl.dart';
import '../../features/vehicles/domain/repositories/vehicle_repository.dart';
import '../../features/vehicles/domain/usecases/add_vehicle_usecase.dart';
import '../../features/vehicles/domain/usecases/delete_vehicle_usecase.dart';
import '../../features/vehicles/domain/usecases/get_user_vehicles_usecase.dart';
import '../../features/vehicles/domain/usecases/set_default_vehicle_usecase.dart';
import '../../features/vehicles/domain/usecases/update_vehicle_usecase.dart';
import '../../features/vehicles/presentation/providers/vehicle_provider.dart';

import '../../features/favorites/data/datasources/favorite_remote_datasource.dart';
import '../../features/favorites/data/repositories/favorite_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorite_repository.dart';
import '../../features/favorites/domain/usecases/get_favorites_usecase.dart';
import '../../features/favorites/domain/usecases/remove_favorite_usecase.dart';
import '../../features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import '../../features/favorites/presentation/providers/favorite_provider.dart';

/// Point unique de câblage manuel des dépendances.
///
/// Les dépendances sont construites selon le schéma :
///
/// DataSource
///     ↓
/// Repository
///     ↓
/// UseCases
///     ↓
/// Provider
///
/// Les instances Firebase utilisées ici sont celles déjà initialisées
/// dans main.dart.
class Injector {
  Injector._();

  // ============================================================
  // AUTHENTIFICATION
  // ============================================================

  static final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSource(
      firebaseAuth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    ),
  );

  /// Instance unique partagée de l'AuthProvider.
  static final AuthProvider authProvider = AuthProvider(
    signInUserCase: SignInUserCase(authRepository),
    signUpUserCase: SignUpUserCase(authRepository),
    verifyStudentUseCase: VerifyStudentUseCase(authRepository),
    sendEmailVerificationUseCase: SendEmailVerificationUseCase(
      authRepository,
    ),
    checkEmailVerificationUseCase: CheckEmailVerificationUseCase(
      authRepository,
    ),
    authRepository: authRepository,
  );

  // ============================================================
  // UNIVERSITÉS
  // ============================================================

  static UniversityProvider createUniversityProvider() {
    final repository = UniversityRepositoryImpl(
      UniversityRemoteDataSource(
        firestore: FirebaseFirestore.instance,
      ),
    );

    return UniversityProvider(
      getUniversitiesUseCase: GetUniversitiesUseCase(repository),
      addUniversityUseCase: AddUniversityUseCase(repository),
    );
  }

  // ============================================================
  // REVIEWS
  // ============================================================

  static ReviewProvider createReviewProvider() {
    final repository = ReviewRepositoryImpl(
      remoteDataSource: ReviewRemoteDataSource(
        FirebaseFirestore.instance,
      ),
    );

    return ReviewProvider(
      createReviewUseCase: CreateReview(repository),
      getReviewsForUserUseCase: GetReviewsForUserUseCase(repository),
    );
  }

  // ============================================================
  // STATISTIQUES
  // ============================================================

  static StatisticsProvider createStatisticsProvider() {
    final remoteDataSource = StatisticsRemoteDataSource(
      firestore: FirebaseFirestore.instance,
    );

    final repository = StatisticsRepositoryImpl(
      remoteDataSource: remoteDataSource,
      getDriverStatisticsUseCase: GetDriverStatistics(),
      getUniversityStatisticsUseCase:
          GetUniversityStatistics(),
    );

    return StatisticsProvider(
      repository: repository,
    );
  }

  // ============================================================
  // PROFIL
  // ============================================================

  static ProfileProvider createProfileProvider() {
    final repository = ProfileRepositoryImpl(
      ProfileRemoteDataSource(
        firestore: FirebaseFirestore.instance,
      ),
    );

    return ProfileProvider(
      getProfileUseCase: GetProfileUseCase(repository),
      updateProfileUseCase: UpdateProfileUseCase(repository),
    );
  }

  // ============================================================
  // BOOKINGS / RÉSERVATIONS
  // ============================================================

  static BookingProvider createBookingProvider() {
    final remoteDataSource = BookingRemoteDataSource(
      firestore: FirebaseFirestore.instance,
    );

    final BookingRepository repository = BookingRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    return BookingProvider(
      requestBookingUseCase: RequestBookingUseCase(
        repository,
      ),
      confirmBookingUseCase: ConfirmBookingUseCase(
        repository,
      ),
      rejectBookingRequestUseCase:
          RejectBookingRequestUseCase(
        repository,
      ),
      cancelBookingUseCase: CancelBookingUseCase(
        repository,
      ),
      repository: repository,
    );
  }

  // ============================================================
  // TRAJETS
  // ============================================================

  static TripProvider createTripProvider() {
    final repository = TripRepositoryImpl(
      remoteDataSource: TripRemoteDataSource(
        firestore: FirebaseFirestore.instance,
      ),
    );

    return TripProvider(
      publishTripUseCase: PublishTripUseCase(repository),
      searchTripsUseCase: SearchTripsUseCase(repository),
      getTripHistoryUseCase: GetTripHistoryUseCase(repository),
    );
  }

  // ============================================================
  // VÉHICULES
  // ============================================================

  static VehicleProvider createVehicleProvider() {
    final VehicleRepository repository = VehicleRepositoryImpl(
      remoteDataSource: VehicleRemoteDataSource(
        firestore: FirebaseFirestore.instance,
      ),
    );

    return VehicleProvider(
      getUserVehiclesUseCase: GetUserVehiclesUseCase(repository),
      addVehicleUseCase: AddVehicleUseCase(repository),
      updateVehicleUseCase: UpdateVehicleUseCase(repository),
      deleteVehicleUseCase: DeleteVehicleUseCase(repository),
      setDefaultVehicleUseCase: SetDefaultVehicleUseCase(repository),
    );
  }

  // ============================================================
  // FAVORIS
  // ============================================================

  static FavoriteProvider createFavoriteProvider() {
    final FavoriteRepository repository = FavoriteRepositoryImpl(
      remoteDataSource: FavoriteRemoteDataSource(
        firestore: FirebaseFirestore.instance,
      ),
    );

    return FavoriteProvider(
      getFavoritesUseCase: GetFavoritesUseCase(repository),
      toggleFavoriteUseCase: ToggleFavoriteUseCase(repository),
      removeFavoriteUseCase: RemoveFavoriteUseCase(repository),
    );
  }
}
