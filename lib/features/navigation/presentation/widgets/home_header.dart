import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onMenuPressed;

  const HomeHeader({
    super.key,
    this.onNotificationPressed,
    this.onProfilePressed,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // MENU
        IconButton(
          onPressed: onMenuPressed,
          icon: const Icon(
            Icons.menu_rounded,
            size: 26,
            color: AppColors.textDark,
          ),
        ),

        // LOGO
        Expanded(
          child: Image.asset(
            'assets/images/CarPoolLite_logo_sn.png',
            height: 60,
            alignment: Alignment.centerLeft,
            fit: BoxFit.contain,
          ),
        ),

        // NOTIFICATION
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: onNotificationPressed,
              icon: const Icon(
                Icons.notifications_none_rounded,
                size: 25,
                color: AppColors.textDark,
              ),
            ),

            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 4),

        // AVATAR
        GestureDetector(
          onTap: onProfilePressed,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/CarPoolLite_logo_s.png',
              fit: BoxFit.cover,
            ),
          ),
        ),

      ],
    );
  }
}