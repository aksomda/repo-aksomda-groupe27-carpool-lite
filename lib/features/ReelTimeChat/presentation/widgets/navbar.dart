import 'package:flutter/material.dart';

class MaBottomNavigationBar
    extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),

      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceAround,
            children: [

              _NavItem(
                icon: Icons.home_outlined,
                label: 'Accueil',
                active: false,
              ),

              _NavItem(
                icon:
                Icons.alt_route_rounded,
                label: 'Trajets',
                active: false,
              ),

              Container(
                width: 58,
                height: 58,
                decoration:
                const BoxDecoration(
                  color:
                  Color(0xFF1468F5),
                  shape:
                  BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              _NavItem(
                icon:
                Icons.chat_bubble_outline,
                label: 'Messages',
                active: true,
              ),

              _NavItem(
                icon:
                Icons.person_outline,
                label: 'Profil',
                active: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [

        Icon(
          icon,
          size: 28,
          color: active
              ? const Color(0xFF1468F5)
              : const Color(0xFF7893BA),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          style: TextStyle(
            color: active
                ? const Color(0xFF1468F5)
                : const Color(0xFF7893BA),
            fontSize: 11,
            fontWeight: active
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),

        if (active)
          Container(
            margin:
            const EdgeInsets.only(
              top: 4,
            ),
            width: 42,
            height: 3,
            decoration:
            BoxDecoration(
              color:
              const Color(0xFF1468F5),
              borderRadius:
              BorderRadius.circular(5),
            ),
          ),
      ],
    );
  }
}