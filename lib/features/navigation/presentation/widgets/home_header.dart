import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;

  const HomeHeader({
    super.key,
    this.onNotificationPressed,
    this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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