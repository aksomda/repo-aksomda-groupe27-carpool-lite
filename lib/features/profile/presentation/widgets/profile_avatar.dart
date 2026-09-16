import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final String? photoUrl;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.radius = 40,
    this.photoUrl,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }

    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';

    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        photoUrl != null && photoUrl!.trim().isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).primaryColor,
      backgroundImage:
          hasPhoto ? NetworkImage(photoUrl!) : null,
      child: hasPhoto
          ? null
          : Text(
              _initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: radius * 0.6,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}