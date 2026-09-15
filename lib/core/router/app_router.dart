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
import '../../features/navigation/presentation/screens/app_dashboard_screen.dart';
import '../../features/trips/presentation/screens/publish_trip_screen.dart';
import '../../features/trips/presentation/screens/search_trips_screen.dart';
import '../../features/trips/presentation/screens/trip_history_screen.dart';
import '../../features/bookings/presentation/screens/booking_requests_screen.dart';
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

/// Seules routes accessibles sans être connecté.
///
/// `/auth/verify-student` en fait partie mais reste atteignable une fois
/// connecté : c'est l'étape qui suit immédiatement l'inscription.
const Set<String> _publicRoutes = {
  '/auth',
  '/auth/register',
  '/auth/verify-student',
};

final GoRouter appRouter = GoRouter(
  initialLocation: '/auth',
  // Sans `refreshListenable`, GoRouter n'évalue `redirect` qu'au moment
  // d'une navigation : une connexion ou une déconnexion ne provoquait
  // aucune réévaluation, et l'utilisateur restait sur un écran auquel il
  // n'avait plus (ou pas encore) droit.
  refreshListenable: Injector.authProvider,
  redirect: (_, state) {
    final location = state.matchedLocation;
    final user = Injector.authProvider.user;
    final isAdmin = (user?.role ?? 'student').toLowerCase() == 'admin';

    // Utilisateur non connecté : tout ce qui n'est pas public est refusé.
    // Auparavant seules les routes /admin étaient protégées ; les écrans
    // métier s'ouvraient donc avec un uid vide — d'où des listes
    // systématiquement vides — ou plantaient sur un `user!`.
    if (user == null) {
      return _publicRoutes.contains(location) ? null : '/auth';
    }

    // Déjà connecté : l'écran de connexion n'a plus de raison d'être.
    if (location == '/auth') {
      return isAdmin ? '/admin/dashboard' : '/home';
    }

    // Espace d'administration réservé au rôle "admin".
    if (location.startsWith('/admin') && !isAdmin) return '/home';

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
      path: '/trips/publish',
      builder: (_, _) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Injector.createTripProvider()),
          ChangeNotifierProvider(create: (_) => Injector.createVehicleProvider()),
        ],
        child: const PublishTripScreen(),
      ),
    ),
    GoRoute(
      path: '/trips/search',
      builder: (_, _) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Injector.createTripProvider()),
          ChangeNotifierProvider(create: (_) => Injector.createBookingProvider()),
        ],
        child: const SearchTripsScreen(),
      ),
    ),
    GoRoute(
      path: '/trips/history',
      builder: (_, _) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Injector.createTripProvider()),
          ChangeNotifierProvider(create: (_) => Injector.createVehicleProvider()),
        ],
        child: const TripHistoryScreen(),
      ),
    ),
    GoRoute(
      path: '/trips',
      builder: (_, _) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Injector.createTripProvider()),
          ChangeNotifierProvider(create: (_) => Injector.createBookingProvider()),
        ],
        child: const SearchTripsScreen(),
      ),
    ),

    GoRoute(
      path: '/bookings',
      builder: (_, _) => ChangeNotifierProvider(
        create: (_) => Injector.createBookingProvider(),
        child: const BookingRequestsScreen(),
      ),
    ),
    GoRoute(
      path: '/vehicles',
      builder: (_, _) => ChangeNotifierProvider(
        create: (_) => Injector.createVehicleProvider(),
        child: const VehicleListScreen(),
      ),
    ),
    GoRoute(
      path: '/chat',
      builder: (_, _) => ProviderScope(
        child: ChatListScreen(authProvider: Injector.authProvider),
      ),
    ),
    GoRoute(
      path: '/notifications',
      // L'identifiant était codé en dur à la chaîne vide : la sous-collection
      // interrogée était `users//notifications`, donc l'écran restait
      // désespérément vide.
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
