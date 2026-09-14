import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/auth/domain/entities/user_entity.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/auth/presentation/providers/auth_provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../widgets/home_header.dart';
import '../widgets/search_trip_card.dart';
// import '../widgets/bottom_navigation.dart'; // masqué temporairement
import '../widgets/quick_access_grid.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  final AuthProvider authProvider;
  const HomeScreen({super.key, required this.authProvider});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void searchTrip() {
    final snackBar = SnackBar(
      content: const Text('Recherche de trajets...'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  late final UserEntity? user;

  @override
  void initState() {
    user = widget.authProvider.user!;
    super.initState();
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.authProvider.signOut();
      if (mounted) context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: false,

      drawer: AppDrawer(authProvider: widget.authProvider),

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: HomeHeader(
                        onMenuPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                        onNotificationPressed: () => context.go('/chat'),
                        onProfilePressed: () => context.go('/profile'),
                      ),
                    ),

                    // SALUTATION
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Text(
                        'Bonjour ${user!.name} ! 👋',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: const Text(
                        'Prêt(e) pour un nouveau trajet ?',
                        style: TextStyle(
                          fontSize: 21,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),

                    // BANNER
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 35, 20, 35),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(27),
                            child: SizedBox(
                              width: double.infinity,
                              child: Image.asset(
                                'assets/images/HomePage_banner.png',
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 15,
                            child: Transform.rotate(
                              angle: -math.pi / 20.0,
                              child: const Text(
                                'Ensemble',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 20,
                            child: Transform.rotate(
                              angle: -math.pi / 20.0,
                              child: const Text(
                                'vers vos \ndestinations !',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // RECHERCHE
                    const SearchTripCard(),

                    const SizedBox(height: 10),

                    // ACCÈS RAPIDE
                    QuickAccessGrid(
                      items: [
                        QuickAccessItem(
                          icon: Icons.star_rounded,
                          label: 'Évaluation\nd\'un trajet',
                          color: AppColors.quickPurple,
                          onTap: () => context.go('/reviews'),
                        ),
                        QuickAccessItem(
                          icon: Icons.inbox_rounded,
                          label: 'Demandes de\nréservation',
                          color: AppColors.quickGreen,
                          onTap: () => context.go('/bookings'),
                        ),
                        QuickAccessItem(
                          icon: Icons.history_rounded,
                          label: 'Historique\nde mes trajets',
                          color: AppColors.quickYellow,
                          onTap: () => context.go('/trips/history'),
                        ),
                        QuickAccessItem(
                          icon: Icons.directions_car_filled_rounded,
                          label: 'Véhicules',
                          color: AppColors.quickBlue,
                          onTap: () => context.go('/vehicles'),
                        ),
                        QuickAccessItem(
                          icon: Icons.bar_chart_rounded,
                          label: 'Statistiques',
                          color: AppColors.quickPurple,
                          onTap: () => context.go('/statistics'),
                        ),
                        QuickAccessItem(
                          icon: Icons.logout_rounded,
                          label: 'Déconnexion',
                          color: AppColors.quickYellow,
                          onTap: _confirmSignOut,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // bottomNavigationBar masquée temporairement (menu du bas désactivé).
      // bottomNavigationBar: HomeBottomNavigation(currentIndex: 0),
    );
  }
}
