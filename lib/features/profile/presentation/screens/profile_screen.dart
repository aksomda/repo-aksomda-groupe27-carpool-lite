
import 'package:flutter/material.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../navigation/presentation/widgets/bottom_navigation.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_screen.dart';

class ProfileColors {
  static const primary = Color(0xFF1478F2);
  static const darkBlue = Color(0xFF103875);
  static const mediumBlue = Color(0xFF5272A8);
  static const lightBlue = Color(0xFFEAF4FF);

  static const green = Color(0xFF0BB59F);
  static const yellow = Color(0xFFFFAA00);
  static const purple = Color(0xFF6551D8);

  static const background = Color(0xFFF7FBFF);
  static const border = Color(0xFFE1ECFA);

  static const red = Color(0xFFE94E4E);
}

class ProfileScreen extends StatefulWidget {

  final AuthProvider authProvider;
  final ProfileProvider profileProvider;

  const ProfileScreen({
    super.key,
    required this.authProvider,
    required this.profileProvider,
  });



  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
    final uid = widget.authProvider.user?.uid;
    if (uid != null) {
      widget.profileProvider.loadProfile(uid);
    }
  }


  int selectedIndex = 4;

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Photo de profil',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: ProfileColors.darkBlue,
                  ),
                ),

                const SizedBox(height: 20),

                ListTile(
                  leading: _BottomSheetIcon(
                    icon: Icons.camera_alt_outlined,
                    color: ProfileColors.primary,
                  ),
                  title: const Text(
                    'Prendre une photo',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                ListTile(
                  leading: _BottomSheetIcon(
                    icon: Icons.photo_library_outlined,
                    color: ProfileColors.primary,
                  ),
                  title: const Text(
                    'Choisir dans la galerie',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                ListTile(
                  leading: _BottomSheetIcon(
                    icon: Icons.delete_outline,
                    color: ProfileColors.red,
                  ),
                  title: const Text(
                    'Supprimer la photo',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Se déconnecter ?',
            style: TextStyle(
              color: ProfileColors.darkBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Voulez-vous vraiment vous déconnecter de votre compte ?',
            style: TextStyle(
              color: ProfileColors.mediumBlue,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.authProvider.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ProfileColors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);


    return AnimatedBuilder(
        animation: widget.profileProvider,
        builder: (context, _) {
          final profile = widget.profileProvider.profile;

          return Scaffold(
            backgroundColor:
            ProfileColors.background,

            body: SafeArea(
              bottom: false,
              child: Stack(
                children: [

                  SingleChildScrollView(
                    physics:
                    const BouncingScrollPhysics(),

                    padding: EdgeInsets.only(
                      left: size.width * 0.052,
                      right: size.width * 0.052,
                      top: 12,
                      bottom: 20,
                    ),

                    child: Column(
                      children: [
                        SizedBox(
                          height: 50,
                          child: Row(
                            children: [
                              Expanded(
                                child: Image.asset(
                                  "assets/images/CarPoolLite_logo_sn.png",
                                  alignment: Alignment.centerLeft,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return const Text(
                                      'CarPool Lite',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight:
                                        FontWeight.bold,
                                        color:
                                        ProfileColors.darkBlue,
                                      ),
                                    );
                                  },
                                ),
                              ),

                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        _ProfileIdentity(
                          userName: "${profile?.name}",
                          university:
                          "${profile?.universityId}",
                          avatarPath:
                          "assets/images/CarPoolLite_logo_s.png",
                          onPhotoPressed:
                          _showPhotoOptions,
                        ),

                        const SizedBox(height: 25),

                        const _StatisticsCard(),

                        const SizedBox(height: 30),

                        _ProfileMenuCard(
                          onInformationPressed: () {
                            _openPage(
                              'Mes informations',
                            );

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EditProfileScreen(
                                      profileProvider: widget.profileProvider,
                                      profile: profile!,
                                    ),
                                  ),
                                );

                          },
                          onTripsPressed: () {
                            _openPage(
                              'Mes trajets',
                            );
                          },
                          onReviewsPressed: () {
                            _openPage(
                              'Mes avis',
                            );
                          },
                          onPreferencesPressed: () {
                            _openPreferences();
                          },
                        ),

                        const SizedBox(height: 24),

                        _LogoutButton(
                          onPressed:
                          _showLogoutDialog,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            bottomNavigationBar:
            HomeBottomNavigation(
              currentIndex: 4,
            ),
          );
        });

  }

  void _openPage(String title) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(title),
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  void _openPreferences() {
    _openPage('Mes préférences');
  }
}


// ============================================================
// PROFILE IDENTITY
// ============================================================

class _ProfileIdentity
    extends StatelessWidget {
  final String userName;
  final String university;
  final String avatarPath;
  final VoidCallback onPhotoPressed;

  const _ProfileIdentity({
    required this.userName,
    required this.university,
    required this.avatarPath,
    required this.onPhotoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 600;

        return Row(
          crossAxisAlignment:
          CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: compact ? 90 : 120,
                  height: compact ? 90 : 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue
                            .withOpacity(0.08),
                        blurRadius: 20,
                        offset:
                        const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior:
                  Clip.antiAlias,
                  child: Image.asset(
                    avatarPath,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) {
                      return Container(
                        color:
                        ProfileColors.lightBlue,
                        child: const Icon(
                          Icons.person,
                          size: 90,
                          color:
                          ProfileColors.primary,
                        ),
                      );
                    },
                  ),
                ),

                Positioned(
                  right: -5,
                  bottom: 2,
                  child: GestureDetector(
                    onTap:
                    onPhotoPressed,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration:
                      BoxDecoration(
                        color:
                        ProfileColors.primary,
                        shape:
                        BoxShape.circle,
                        border:
                        Border.all(
                          color:
                          Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue
                                .withOpacity(
                                0.18),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 35),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour $userName ',
                    style: TextStyle(
                      fontSize:
                      compact ? 20 : 25,
                      fontWeight:
                      FontWeight.w800,
                      color:
                      ProfileColors.darkBlue,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                          0xFFE4F1FF),
                      borderRadius:
                      BorderRadius.circular(
                          30),
                    ),
                    child: Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.school,
                          color:
                          ProfileColors.primary,
                          size: 20,
                        ),

                        const SizedBox(
                            width: 10),

                        Flexible(
                          child: Text(
                            university,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              color:
                              ProfileColors.primary,
                              fontWeight:
                              FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// STATISTICS
// ============================================================

class _StatisticsCard extends StatelessWidget {
  const _StatisticsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 27,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
            Colors.blue.withOpacity(0.07),
            blurRadius: 22,
            offset:
            const Offset(0, 7),
          ),
        ],
      ),
      child: const Row(
        children: [
          _StatItem(
            icon: Icons.directions_car,
            value: '3',
            label: 'Trajets proposés',
            color:
            ProfileColors.primary,
          ),

          _StatDivider(),

          _StatItem(
            icon: Icons.people_alt,
            value: '5',
            label: 'Trajets effectués',
            color:
            ProfileColors.green,
          ),

          _StatDivider(),

          _StatItem(
            icon: Icons.star,
            value: '4.8',
            label: 'Note moyenne',
            color:
            ProfileColors.yellow,
          ),

          _StatDivider(),

          _StatItem(
            icon: Icons.verified_user,
            value: '100%',
            label: 'Profil vérifié',
            color:
            ProfileColors.primary,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 35,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 29,
              fontWeight:
              FontWeight.w800,
              color:
              ProfileColors.darkBlue,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            textAlign:
            TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color:
              ProfileColors.mediumBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 90,
      color: ProfileColors.border,
    );
  }
}

// ============================================================
// PROFILE MENU
// ============================================================

class _ProfileMenuCard
    extends StatelessWidget {
  final VoidCallback onInformationPressed;
  final VoidCallback onTripsPressed;
  final VoidCallback onReviewsPressed;
  final VoidCallback onPreferencesPressed;

  const _ProfileMenuCard({
    required this.onInformationPressed,
    required this.onTripsPressed,
    required this.onReviewsPressed,
    required this.onPreferencesPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
            Colors.blue.withOpacity(0.07),
            blurRadius: 22,
            offset:
            const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProfileMenuItem(
            icon: Icons.person,
            iconColor:
            ProfileColors.primary,
            backgroundColor:
            const Color(0xFFE5F1FF),
            title: 'Mes informations',
            subtitle:
            'Nom, e-mail, téléphone, établissement...',
            onTap:
            onInformationPressed,
          ),

          _MenuDivider(),

          _ProfileMenuItem(
            icon: Icons.route,
            iconColor:
            ProfileColors.green,
            backgroundColor:
            const Color(0xFFE2F8F4),
            title: 'Mes trajets',
            subtitle:
            'Voir mes trajets proposés et réservés',
            onTap: onTripsPressed,
          ),

          _MenuDivider(),

          _ProfileMenuItem(
            icon: Icons.star,
            iconColor:
            ProfileColors.yellow,
            backgroundColor:
            const Color(0xFFFFF2D1),
            title: 'Mes avis',
            subtitle:
            'Ce que les autres disent de moi',
            onTap: onReviewsPressed,
          ),

          _MenuDivider(),

          _ProfileMenuItem(
            icon: Icons.settings,
            iconColor:
            ProfileColors.purple,
            backgroundColor:
            const Color(0xFFEDEBFF),
            title: 'Mes préférences',
            subtitle:
            'Notifications, confidentialité, langue...',
            onTap:
            onPreferencesPressed,
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem
    extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(18),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          vertical: 13,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
              BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 31,
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                    const TextStyle(
                      fontSize: 19,
                      fontWeight:
                      FontWeight.w700,
                      color:
                      ProfileColors.darkBlue,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    const TextStyle(
                      fontSize: 15,
                      color:
                      ProfileColors.mediumBlue,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              size: 33,
              color:
              ProfileColors.darkBlue,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      color: ProfileColors.border,
    );
  }
}

// ============================================================
// LOGOUT
// ============================================================

class _LogoutButton
    extends StatelessWidget {
  final VoidCallback onPressed;

  const _LogoutButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius:
        BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          height: 50,
          padding:
          const EdgeInsets.symmetric(
            horizontal: 28,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F5),
            borderRadius:
            BorderRadius.circular(20),
            border: Border.all(
              color:
              const Color(0xFFFFE1E1),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 25,
                color:
                ProfileColors.red,
              ),

              const SizedBox(width: 25),

              const Expanded(
                child: Text(
                  'Se déconnecter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    ProfileColors.red,
                  ),
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                size: 32,
                color:
                ProfileColors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ============================================================
// BOTTOM SHEET ICON
// ============================================================

class _BottomSheetIcon
    extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _BottomSheetIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
      ),
    );
  }
}