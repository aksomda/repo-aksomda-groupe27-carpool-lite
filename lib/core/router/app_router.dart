
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
import '../../features/chat/presentation/screens/conversations_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/reviews/presentation/screens/user_reviews_screen.dart';
import '../../features/campus/presentation/pages/campus_list_page.dart';
import '../../features/formations/presentation/pages/formation_list_page.dart';
import '../../features/levels/presentation/pages/academic_level_list_page.dart';
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
    GoRoute(path: '/auth', builder: (_, __) => LoginScreen(authProvider: Injector.authProvider)),
    GoRoute(path: '/auth/register', builder: (_, __) => RegisterScreen(authProvider: Injector.authProvider)),
    GoRoute(path: '/auth/verify-student', builder: (_, __) => VerifyStudentScreen(authProvider: Injector.authProvider)),
    GoRoute(path: '/auth/verify-email', builder: (_, __) => EmailOtpScreen(authProvider: Injector.authProvider)),
    GoRoute(path: '/home', builder: (_, __) => AppDashboardScreen(authProvider: Injector.authProvider)),
    GoRoute(path: '/profile', builder: (_, __) => const Scaffold(body: Center(child: Text('Profil')))),
    GoRoute(path: '/universities', builder: (_, __) => ChangeNotifierProvider(create: (_) => Injector.createUniversityProvider(), child: const UniversitySelectionScreen())),

    GoRoute(path: '/trips/publish', builder: (_, __) => const PublishTripScreen()),
    GoRoute(path: '/trips/search', builder: (_, __) => const SearchTripsScreen()),
    GoRoute(path: '/trips/history', builder: (_, __) => const TripHistoryScreen()),
    GoRoute(path: '/trips', builder: (_, __) => const SearchTripsScreen()),

    GoRoute(path: '/bookings', builder: (_, __) => const MyBookingsScreen()),
    GoRoute(path: '/vehicles', builder: (_, __) => const VehicleListScreen()),
    GoRoute(path: '/chat', builder: (_, __) => const ConversationsScreen()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: '/reviews', builder: (_, __) => const UserReviewsScreen()),

    GoRoute(path: '/admin/users', builder: (_, __) => const UserManagementScreen()),
    GoRoute(path: '/admin/universities', builder: (_, __) => const UniversityListPage()),
    GoRoute(path: '/admin/campuses', builder: (_, __) => const CampusListPage()),
    GoRoute(path: '/admin/formations', builder: (_, __) => const FormationListPage()),
    GoRoute(path: '/admin/levels', builder: (_, __) => const AcademicLevelListPage()),
    GoRoute(path: '/statistics', builder: (_, __) => const Scaffold(body: Center(child: Text('Statistiques')))),
  ],
  errorBuilder: (_, state) => Scaffold(body: Center(child: Text('Route introuvable : ${state.error}'))),
);
