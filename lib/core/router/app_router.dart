import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/chat/presentation/screens/chat_list_screen.dart';

import '../../features/navigation/presentation/screens/home_screen.dart';
import '../../features/notification/presentation/screens/notification_screen.dart';
import '../di/injector.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/verify_student_screen.dart';
import '../../features/universities/presentation/screens/university_selection_screen.dart';
import '../../features/navigation/presentation/screens/app_dashboard_screen.dart';
import '../../features/trips/presentation/screens/publish_trip_screen.dart';
import '../../features/trips/presentation/screens/search_trips_screen.dart';
import '../../features/trips/presentation/screens/trip_history_screen.dart';
import '../../features/bookings/presentation/screens/my_bookings_screen.dart';
import '../../features/vehicles/presentation/screens/vehicle_list_screen.dart';
import '../../features/reviews/presentation/screens/user_reviews_screen.dart';
import '../../features/reviews/presentation/pages/create_review_page.dart';
import '../../features/statistics/presentation/screens/statistics_dashboard_screen.dart';
import '../../features/navigation/presentation/screens/coming_soon_screen.dart';
import '../../features/campus/presentation/pages/campus_list_page.dart';
import '../../features/formations/presentation/pages/formation_list_page.dart';
import '../../features/levels/presentation/pages/academic_level_list_page.dart';
import '../../features/ufrs/presentation/pages/ufr_list_page.dart';
import '../../features/universities/presentation/pages/university_list_page.dart';
import '../../features/user_management/presentation/screens/user_management_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/bookings/presentation/providers/booking_provider.dart';
import '../../features/vehicles/presentation/screens/add_vehicle_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/auth',
  redirect: (_, state) {
    final location = state.matchedLocation;
    final user = Injector.authProvider.user;
    final isAdmin = (user?.role ?? 'student').toLowerCase() == 'admin';

    final isAdminRoute = location.startsWith('/admin');
    if (isAdminRoute) {
      if (user == null) return '/auth';
      if (!isAdmin) return '/home';
      return null;
    }

    // Les écrans ci-dessous lisent tous `Injector.authProvider.user?.uid`.
    // Sans ce garde-fou, un utilisateur non connecté y accédait avec un
    // identifiant vide et n'obtenait qu'un écran vide, sans explication.
    const protectedRoutes = <String>[
      '/home',
      '/profile',
      '/trips',
      '/bookings',
      '/vehicles',
      '/favorites',
      '/reviews',
      '/notifications',
      '/chat',
      '/statistics',
    ];

    final isProtected = protectedRoutes.any(
      (route) => location == route || location.startsWith('$route/'),
    );

    if (isProtected && user == null) return '/auth';

    // Un administrateur qui atterrit sur l'accueil étudiant (ex. juste
    // après connexion) est redirigé vers son propre tableau de bord.
    if (location == '/home' && isAdmin) return '/admin/dashboard';

    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
      builder: (_, _) => LoginScreen(authProvider: Injector.authProvider),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (_, _) => RegisterScreen(authProvider: Injector.authProvider),
    ),
    GoRoute(
      path: '/auth/verify-student',
      builder: (_, _) =>
          VerifyStudentScreen(authProvider: Injector.authProvider),
    ),
    //GoRoute(path: '/auth/verify-email', builder: (_, _) => EmailOtpScreen(authProvider: Injector.authProvider)),
    GoRoute(
      path: '/home',
      builder: (_, _) => HomeScreen(authProvider: Injector.authProvider),
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (_, _) => AdminHomeScreen(authProvider: Injector.authProvider),
    ),
    GoRoute(
      path: '/profile',
      builder: (_, _) => ProfileScreen(
        authProvider: Injector.authProvider,
        profileProvider: Injector.createProfileProvider(),
      ),
    ),
    GoRoute(
      path: '/universities',
      builder: (_, _) => ChangeNotifierProvider(
        create: (_) => Injector.createUniversityProvider(),
        child: const UniversitySelectionScreen(),
      ),
    ),

    GoRoute(
      path: '/trips/publish',
      builder: (_, _) => ChangeNotifierProvider(
        create: (_) => Injector.createTripProvider(),
        child: const PublishTripScreen(),
      ),
    ),
    // La recherche affiche un bouton « favori » sur chaque trajet : elle a
    // donc besoin du TripProvider ET du FavoriteProvider.
    GoRoute(
      path: '/trips/search',
      builder: (context, state) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => Injector.createTripProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => Injector.createFavoriteProvider(),
          ),
        ],
        child: SearchTripsScreen(
          initialDeparture: state.uri.queryParameters['departure'],
          initialArrival: state.uri.queryParameters['arrival'],
          initialDate: state.uri.queryParameters['date'],
          initialPassengers: int.tryParse(
            state.uri.queryParameters['passengers'] ?? '',
          ),
        ),
      ),
    ),
    GoRoute(
      path: '/trips/history',
      builder: (_, _) => ChangeNotifierProvider(
        create: (_) => Injector.createTripProvider(),
        child: const TripHistoryScreen(),
      ),
    ),
    GoRoute(
      path: '/trips',
      builder: (_, _) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => Injector.createTripProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => Injector.createFavoriteProvider(),
          ),
        ],
        child: const SearchTripsScreen(),
      ),
    ),

    GoRoute(
  path: '/bookings',
  builder: (_, _) {
    final user = Injector.authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Utilisateur non connecté'),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => Injector.createBookingProvider(),
      child: Builder(
        builder: (context) {
          return MyBookingsScreen(
            bookingProvider: context.read<BookingProvider>(),
            passengerId: user.uid,
          );
        },
      ),
    );
  },
),
    GoRoute(
      path: '/vehicles',
      builder: (_, _) => ChangeNotifierProvider(
        create: (_) => Injector.createVehicleProvider(),
        child: VehicleListScreen(
          ownerId: Injector.authProvider.user?.uid ?? '',
        ),
      ),
    ),
    GoRoute(
      path: '/vehicles/add',
      builder: (_, _) => ChangeNotifierProvider(
        create: (_) => Injector.createVehicleProvider(),
        child: AddVehicleScreen(
          ownerId: Injector.authProvider.user?.uid ?? '',
        ),
      ),
    ),
    GoRoute(
      path: '/favorites',
      builder: (_, _) => ChangeNotifierProvider(
        create: (_) => Injector.createFavoriteProvider(),
        child: FavoritesScreen(
          userId: Injector.authProvider.user?.uid ?? '',
        ),
      ),
    ),
    GoRoute(
      path: '/chat',
      builder: (_, _) => ProviderScope(
        child: ChatListScreen(authProvider: Injector.authProvider),
      ),
    ),
    // Correctif : l'identifiant était codé en dur à '' — la requête
    // Firestore ne renvoyait donc jamais aucune notification, quel que
    // soit l'utilisateur connecté.
    GoRoute(
      path: '/notifications',
      builder: (_, _) => NotificationsScreen(
        userId: Injector.authProvider.user?.uid ?? '',
      ),
    ),
    GoRoute(
      path: '/reviews',
      builder: (_, _) => ChangeNotifierProvider(
        create: (_) => Injector.createReviewProvider(),
        child: UserReviewsScreen(userId: Injector.authProvider.user?.uid ?? ''),
      ),
    ),
    GoRoute(
      path: '/reviews/create',
      builder: (_, state) {
        final params = state.uri.queryParameters;
        final user = Injector.authProvider.user;
        return ChangeNotifierProvider(
          create: (_) => Injector.createReviewProvider(),
          child: CreateReviewPage(
            tripId: params['tripId'] ?? '',
            bookingId: params['bookingId'] ?? '',
            reviewerId: user?.uid ?? '',
            reviewedUserId: params['reviewedUserId'] ?? '',
            universityId: params['universityId'] ?? user?.universityId ?? '',
          ),
        );
      },
    ),

    GoRoute(
      path: '/admin/users',
      builder: (_, _) => const UserManagementScreen(),
    ),
    GoRoute(
      path: '/admin/universities',
      builder: (_, _) => const UniversityListPage(),
    ),
    GoRoute(path: '/admin/campuses', builder: (_, _) => const CampusListPage()),
    GoRoute(
      path: '/admin/formations',
      builder: (_, _) => const FormationListPage(),
    ),
    GoRoute(
      path: '/admin/levels',
      builder: (_, _) => const AcademicLevelListPage(),
    ),
    GoRoute(path: '/admin/ufrs', builder: (_, _) => const UfrListPage()),
    GoRoute(
      path: '/admin/reports',
      builder: (_, _) => const ComingSoonScreen(
        title: 'Signalements',
        icon: Icons.warning_amber_rounded,
      ),
    ),
    GoRoute(
      path: '/admin/blacklist',
      builder: (_, _) => const ComingSoonScreen(
        title: 'Liste noire',
        icon: Icons.block_outlined,
      ),
    ),
    GoRoute(
      path: '/admin/settings',
      builder: (_, _) => const ComingSoonScreen(
        title: 'Paramètres généraux',
        icon: Icons.settings_outlined,
      ),
    ),
    GoRoute(
      path: '/admin/logs',
      builder: (_, _) => const ComingSoonScreen(
        title: 'Logs / Historique',
        icon: Icons.history,
      ),
    ),
    GoRoute(
      path: '/statistics',
      builder: (_, _) => ChangeNotifierProvider(
        create: (_) => Injector.createStatisticsProvider(),
        child: DriverStatisticsScreen(
          driverId: Injector.authProvider.user?.uid ?? '',
        ),
      ),
    ),
    GoRoute(
      path: '/admin/statistics',
      builder: (_, _) => ChangeNotifierProvider(
        create: (_) => Injector.createStatisticsProvider(),
        child: UniversityStatisticsScreen(
          universityId: Injector.authProvider.user?.universityId ?? '',
        ),
      ),
    ),
  ],
  errorBuilder: (_, state) =>
      Scaffold(body: Center(child: Text('Route introuvable : ${state.error}'))),
);
