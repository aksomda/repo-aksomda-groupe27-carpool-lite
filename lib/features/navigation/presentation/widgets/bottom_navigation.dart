import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class HomeBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const HomeBottomNavigation({
    super.key,
    required this.currentIndex,
  });


  void _createTrip() {
    // TODO :
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => const CreateTripScreen(),
    //   ),
    // );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Accueil',
                  selected: currentIndex == 0,
                  onTap: () => context.go('/home'),
                ),

                _NavItem(
                  icon: Icons.directions_car_outlined,
                  label: 'Trajets',
                  selected: currentIndex == 1,
                  onTap: () => context.go('/trips'),
                ),

                const SizedBox(width: 90),

                _NavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Messages',
                  selected: currentIndex == 3,
                  onTap: () => context.go('/chat'),
                ),

                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  selected: currentIndex == 4,
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),

            Positioned(
              top: -30,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _createTrip,
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary
                              .withOpacity(0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
              ),
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
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 31,
              color: selected
                  ? AppColors.primary
                  : AppColors.textGrey,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: selected
                    ? AppColors.primary
                    : AppColors.textGrey,
              ),
            ),

            const SizedBox(height: 4),

            AnimatedContainer(
              duration:
              const Duration(milliseconds: 200),
              width: selected ? 40 : 0,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius:
                BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}