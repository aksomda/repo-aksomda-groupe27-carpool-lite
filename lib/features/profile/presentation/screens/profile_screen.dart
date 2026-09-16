import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../navigation/presentation/widgets/app_drawer.dart';
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
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _placeholderTripsProposed = 3;
  static const _placeholderTripsCompleted = 5;
  static const _placeholderRating = 4.8;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    final uid = widget.authProvider.user?.uid;

    if (uid != null) {
      widget.profileProvider.loadProfile(uid);
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final uid = widget.authProvider.user?.uid;

    if (uid == null) {
      _comingSoon('Utilisateur non connecté.');
      return;
    }

    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (picked == null) {
        return;
      }

      final Uint8List bytes = await picked.readAsBytes();

      if (!mounted) {
        return;
      }

      final success = await widget.profileProvider.updatePhoto(uid, bytes);

      if (!mounted) {
        return;
      }

      if (success) {
        _comingSoon('Photo de profil mise à jour.');
      } else {
        _comingSoon(
          widget.profileProvider.errorMessage ??
              "Échec de l'envoi de la photo.",
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _comingSoon('Impossible de sélectionner la photo.');
    }
  }

  void _comingSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter de CarPool Lite ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Se déconnecter',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.authProvider.signOut();

      if (!mounted) {
        return;
      }

      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.profileProvider,
      builder: (context, _) {
        final profile = widget.profileProvider.profile;
        final isLoading = widget.profileProvider.isLoading;
        final errorMessage = widget.profileProvider.errorMessage;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: AppDrawer(authProvider: widget.authProvider),

          body: SafeArea(
            child: isLoading && profile == null
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null && profile == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(errorMessage, textAlign: TextAlign.center),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                    children: [
                      _ProfileHeader(
                        onMenuTap: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                        onSettingsTap: () {
                          _comingSoon('Préférences bientôt disponibles.');
                        },
                      ),

                      const SizedBox(height: 24),

                      Center(
                        child: _AvatarWithEditButton(
                          name: profile?.name ?? '',
                          photoUrl: profile?.photoUrl,
                          isUploading: widget.profileProvider.isUploadingPhoto,
                          onEditTap: _pickAndUploadPhoto,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: Text(
                          'Bonjour ${profile?.name ?? ''}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Center(
                        child: Text(
                          profile?.sex == Sex.femme ? 'Étudiante' : 'Étudiant',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _StatsRow(
                        tripsProposed: _placeholderTripsProposed,
                        tripsCompleted: _placeholderTripsCompleted,
                        rating: _placeholderRating,
                        isVerified: profile?.isVerified ?? false,
                      ),

                      const SizedBox(height: 28),

                      // MES INFORMATIONS
                      _MenuTile(
                        icon: Icons.person_outline_rounded,
                        iconBg: const Color(0xFFEDE7FF),
                        iconColor: AppColors.accentPurple,
                        title: 'Mes informations',
                        subtitle: 'Nom, e-mail, téléphone, établissement',
                        onTap: profile == null
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EditProfileScreen(
                                      profileProvider: widget.profileProvider,
                                      profile: profile,
                                    ),
                                  ),
                                );
                              },
                      ),

                      const SizedBox(height: 12),

                      // MES TRAJETS
                      _MenuTile(
                        icon: Icons.directions_car_outlined,
                        iconBg: const Color(0xFFE1F5EA),
                        iconColor: AppColors.success,
                        title: 'Mes trajets',
                        subtitle: 'Voir mes trajets proposés et réservés',
                        onTap: () {
                          context.push('/trips/history');
                        },
                      ),

                      const SizedBox(height: 12),

                      // MES AVIS
                      _MenuTile(
                        icon: Icons.star_outline_rounded,
                        iconBg: AppColors.accentYellow.withValues(alpha: 0.18),
                        iconColor: AppColors.accentYellow,
                        title: 'Mes avis',
                        subtitle: 'Ce que les autres disent de moi',
                        onTap: () {
                          context.push('/reviews');
                        },
                      ),

                      const SizedBox(height: 12),

                      // MES PRÉFÉRENCES
                      _MenuTile(
                        icon: Icons.settings_outlined,
                        iconBg: AppColors.inputFill,
                        iconColor: AppColors.primary,
                        title: 'Mes préférences',
                        subtitle: 'Notifications, langue, confidentialité',
                        onTap: () {
                          _comingSoon('Préférences bientôt disponibles.');
                        },
                      ),

                      const SizedBox(height: 24),

                      // DÉCONNEXION
                      _SignOutButton(onTap: _confirmSignOut),
                    ],
                  ),
          ),

          // NAVIGATION DU BAS
          bottomNavigationBar: const HomeBottomNavigation(currentIndex: 4),
        );
      },
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class _ProfileHeader extends StatelessWidget {
  final VoidCallback onSettingsTap;
  final VoidCallback onMenuTap;

  const _ProfileHeader({required this.onSettingsTap, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onMenuTap,
          icon: const Icon(Icons.menu_rounded, color: AppColors.navy),
        ),

        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/logo_carpoollite.png',
            width: 38,
            height: 38,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(width: 10),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CarPool Lite',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              Text(
                'Covoiturage pour étudiants',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: onSettingsTap,
          icon: const Icon(Icons.settings_outlined, color: AppColors.navy),
        ),
      ],
    );
  }
}

// ============================================================
// AVATAR
// ============================================================

class _AvatarWithEditButton extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final bool isUploading;
  final VoidCallback onEditTap;

  const _AvatarWithEditButton({
    required this.name,
    this.photoUrl,
    this.isUploading = false,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ProfileAvatar(name: name, radius: 48, photoUrl: photoUrl),

        if (isUploading)
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
          ),

        Positioned(
          right: -2,
          bottom: -2,
          child: GestureDetector(
            onTap: isUploading ? null : onEditTap,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// STATISTIQUES
// ============================================================

class _StatsRow extends StatelessWidget {
  final int tripsProposed;
  final int tripsCompleted;
  final double rating;
  final bool isVerified;

  const _StatsRow({
    required this.tripsProposed,
    required this.tripsCompleted,
    required this.rating,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.directions_car_filled_rounded,
            iconColor: AppColors.primary,
            value: '$tripsProposed',
            label: 'Trajets\nproposés',
          ),

          _StatDivider(),

          _StatItem(
            icon: Icons.people_alt_rounded,
            iconColor: AppColors.success,
            value: '$tripsCompleted',
            label: 'Trajets\neffectués',
          ),

          _StatDivider(),

          _StatItem(
            icon: Icons.star_rounded,
            iconColor: AppColors.accentYellow,
            value: '$rating',
            label: 'Note\nmoyenne',
          ),

          _StatDivider(),

          _StatItem(
            icon: Icons.verified_user_rounded,
            iconColor: isVerified ? AppColors.success : AppColors.textSecondary,
            value: isVerified ? '100%' : '0%',
            label: 'Profil\nvérifié',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SÉPARATEUR DES STATISTIQUES
// ============================================================

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 44, color: AppColors.border);
  }
}

// ============================================================
// ITEM STATISTIQUE
// ============================================================

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MENU TILE
// ============================================================

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BOUTON DÉCONNEXION
// ============================================================

class _SignOutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SignOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error),

            SizedBox(width: 12),

            Expanded(
              child: Text(
                'Se déconnecter',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),

            Icon(Icons.chevron_right_rounded, color: AppColors.error),
          ],
        ),
      ),
    );
  }
}
