
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/chat/presentation/screens/chat_list_screen.dart';

import '../di/injector.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/verify_student_screen.dart';
import '../../features/auth/presentation/screens/email_otp_screen.dart';
import '../../features/universities/presentation/screens/university_selection_screen.dart';
import '../../features/navigation/presentation/screens/app_dashboard_screen.dart';
import '../../features/trips/presentation/screens/publish_trip_screen.dart';
import '../../features/trips/presentation/screens/search_trips_screen.dart';
import '../../features/trips/presentation/screens/trip_history_screen.dart';
import '../../features/bookings/presentation/screens/my_bookings_screen.dart';
import '../../features/vehicles/presentation/screens/vehicle_list_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/reviews/presentation/screens/user_reviews_screen.dart';
import '../../features/campus/presentation/pages/campus_list_page.dart';
import '../../features/formations/presentation/pages/formation_list_page.dart';
import '../../features/levels/presentation/pages/academic_level_list_page.dart';
import '../../features/ufrs/presentation/pages/ufr_list_page.dart';
import '../../features/universities/presentation/pages/university_list_page.dart';
import '../../features/user_management/presentation/screens/user_management_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/auth',
  redirect: (_, state) {
    final location = state.matchedLocation;
    final isAdminRoute = location.startsWith('/admin');
    if (!isAdminRoute) return null;

    final user = Injector.authProvider.user;
    final isAdmin = (user?.role ?? 'student').toLowerCase() == 'admin';
    if (user == null) return '/auth';
    if (!isAdmin) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/auth', builder: (_, _) => LoginScreen(authProvider: Injector.authProvider)),
    GoRoute(path: '/auth/register', builder: (_, _) => RegisterScreen(authProvider: Injector.authProvider)),
    GoRoute(path: '/auth/verify-student', builder: (_, _) => VerifyStudentScreen(authProvider: Injector.authProvider)),
    GoRoute(path: '/auth/verify-email', builder: (_, _) => EmailOtpScreen(authProvider: Injector.authProvider)),
    GoRoute(path: '/home', builder: (_, _) => AppDashboardScreen(authProvider: Injector.authProvider)),
    GoRoute(path: '/profile', builder: (_, _) => const Scaffold(body: Center(child: Text('Profil')))),
    GoRoute(path: '/universities', builder: (_, _) => ChangeNotifierProvider(create: (_) => Injector.createUniversityProvider(), child: const UniversitySelectionScreen())),

    GoRoute(path: '/trips/publish', builder: (_, _) => const PublishTripScreen()),
    GoRoute(path: '/trips/search', builder: (_, _) => const SearchTripsScreen()),
    GoRoute(path: '/trips/history', builder: (_, _) => const TripHistoryScreen()),
    GoRoute(path: '/trips', builder: (_, _) => const SearchTripsScreen()),

    GoRoute(path: '/bookings', builder: (_, _) => const MyBookingsScreen()),
    GoRoute(path: '/vehicles', builder: (_, _) => const VehicleListScreen()),
    GoRoute(path: '/chat', builder: (_, _) => ProviderScope(child: ChatListScreen(authProvider: Injector.authProvider))),
    GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
    GoRoute(path: '/reviews', builder: (_, _) => const UserReviewsScreen()),

    GoRoute(path: '/admin/users', builder: (_, _) => const UserManagementScreen()),
    GoRoute(path: '/admin/universities', builder: (_, _) => const UniversityListPage()),
    GoRoute(path: '/admin/campuses', builder: (_, _) => const CampusListPage()),
    GoRoute(path: '/admin/formations', builder: (_, _) => const FormationListPage()),
    GoRoute(path: '/admin/levels', builder: (_, _) => const AcademicLevelListPage()),
    GoRoute(path: '/admin/ufrs', builder: (_, _) => const UfrListPage()),
    GoRoute(path: '/statistics', builder: (_, _) => const Scaffold(body: Center(child: Text('Statistiques')))),
  ],
  errorBuilder: (_, state) => Scaffold(body: Center(child: Text('Route introuvable : ${state.error}'))),
);
