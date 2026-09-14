
import 'package:flutter/material.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../navigation/presentation/widgets/bottom_navigation.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_avatar.dart';
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
                    // TODO: brancher la capture caméra (image_picker) puis
                    // appeler widget.profileProvider.updatePhoto(...).
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
                    // TODO: brancher la sélection galerie (image_picker) puis
                    // appeler widget.profileProvider.updatePhoto(...).
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
                    // TODO: brancher la suppression de la photo de profil.
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
    return AnimatedBuilder(
        animation: widget.profileProvider,
        builder: (context, _) {
          final profile = widget.profileProvider.profile;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mon profil'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Déconnexion',
                onPressed: () => widget.authProvider.signOut(),
              ),
            ],
          ),
          body: widget.profileProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.profileProvider.errorMessage != null
                  ? Center(child: Text(widget.profileProvider.errorMessage!))
                  : profile == null
                      ? const Center(child: Text('Aucun profil.'))
                      : ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ProfileAvatar(name: profile.name, radius: 48),
                                  Positioned(
                                    right: -4,
                                    bottom: -4,
                                    child: GestureDetector(
                                      onTap: _showPhotoOptions,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: ProfileColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                profile.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Center(
                              child: Text(
                                profile.email,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ListTile(
                              leading: const Icon(Icons.phone),
                              title: const Text('Téléphone'),
                              subtitle: Text(profile.phone),
                            ),
                            ListTile(
                              leading: const Icon(Icons.wc),
                              title: const Text('Sexe'),
                              subtitle: Text(
                                profile.sex == Sex.homme ? 'Homme' : 'Femme',
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                profile.isVerified
                                    ? Icons.verified
                                    : Icons.hourglass_empty,
                                color:
                                    profile.isVerified ? Colors.green : Colors.orange,
                              ),
                              title: const Text('Statut étudiant'),
                              subtitle: Text(
                                profile.isVerified ? 'Vérifié' : 'Non vérifié',
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EditProfileScreen(
                                      profileProvider: widget.profileProvider,
                                      profile: profile,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Modifier mon profil'),
                            ),
                            const SizedBox(height: 24),
                            _ProfileMenuCard(
                              onInformationPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EditProfileScreen(
                                      profileProvider: widget.profileProvider,
                                      profile: profile,
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
                              onPressed: _showLogoutDialog,
                            ),
                          ],
                        ),
          bottomNavigationBar: HomeBottomNavigation(currentIndex: 4),
        );
      },
    );
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
            Colors.blue.withValues(alpha: 0.07),
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
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
      ),
    );
  }
}
