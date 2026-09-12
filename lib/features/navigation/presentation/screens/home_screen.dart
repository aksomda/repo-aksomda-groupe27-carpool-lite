import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/auth/presentation/providers/auth_provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../widgets/home_header.dart';
import '../widgets/search_trip_card.dart';
import '../widgets/bottom_navigation.dart';

class HomeScreen extends StatefulWidget {

  final AuthProvider authProvider;
  const HomeScreen({
    super.key, required this.authProvider,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {


  void _searchTrip() {
    final snackBar = SnackBar(
      content: const Text(
        'Recherche de trajets...',
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(snackBar);
  }

  late final user;

  @override
  void initState() {
    user = widget.authProvider.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          20,
                          20,
                          0,
                        ),
                        child: HomeHeader(
                          onNotificationPressed: () => context.go('/chat'),
                          onProfilePressed: () => context.go('/profil'),
                        ),
                    ),

                    // SALUTATION
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        0,
                      ),
                      child: Text(
                        'Bonjour ${user.name} ! 👋',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        0,
                      ),
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
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        35,
                        20,
                        35,
                      ),
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
                            child:
                            Transform.rotate(
                              angle:  -math.pi / 20.0,
                              child: const Text(
                                'Ensemble',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),),
                          Positioned(
                            bottom: 10,
                            left: 20,
                            child:
                            Transform.rotate(
                              angle: -math.pi / 20.0,
                              child: const Text(
                                'vers vos \ndestinations !',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),),

                        ],
                      ),
                    ),


                    // RECHERCHE
                    const SearchTripCard(),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
      HomeBottomNavigation(
        currentIndex: 0,
      ),
    );
  }
}
