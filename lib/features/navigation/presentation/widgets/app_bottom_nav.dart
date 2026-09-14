import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

enum AppTab { home, trip, message, profile }

class AppBottomNavBar extends StatelessWidget {
  final AppTab currentTab;
  final VoidCallback? onHomeTap;
  final VoidCallback? onTripTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onProfileTap;

  const AppBottomNavBar({
    super.key,
    required this.currentTab,
    this.onHomeTap,
    this.onTripTap,
    this.onMessageTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: AppColors.surface,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Accueil',
              selected: currentTab == AppTab.home,
              onTap: onHomeTap,
            ),
            _NavItem(
              icon: Icons.directions_car_outlined,
              label: 'Trajet',
              selected: currentTab == AppTab.trip,
              onTap: onTripTap,
            ),
            const SizedBox(width: 40), // espace réservé au bouton flottant central
            _NavItem(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Message',
              selected: currentTab == AppTab.message,
              onTap: onMessageTap,
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profil',
              selected: currentTab == AppTab.profile,
              onTap: onProfileTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _NavItem({required this.icon, required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}