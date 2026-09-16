import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorite_provider.dart';

/// Bouton « cœur » permettant d'ajouter ou de retirer un trajet des
/// favoris. Attend un [FavoriteProvider] fourni plus haut dans l'arbre.
class FavoriteButton extends StatelessWidget {
  final String userId;
  final String tripId;
  final String departure;
  final String arrival;
  final DateTime departureDateTime;
  final double pricePerSeat;
  final String driverId;

  /// Taille de l'icône. Utile pour l'intégrer dans une carte compacte.
  final double size;

  const FavoriteButton({
    super.key,
    required this.userId,
    required this.tripId,
    required this.departure,
    required this.arrival,
    required this.departureDateTime,
    required this.pricePerSeat,
    required this.driverId,
    this.size = 24,
  });

  Future<void> _toggle(BuildContext context) async {
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Connectez-vous pour ajouter des trajets à vos favoris.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = context.read<FavoriteProvider>();

    await provider.toggleFavorite(
      userId: userId,
      tripId: tripId,
      departure: departure,
      arrival: arrival,
      departureDateTime: departureDateTime,
      pricePerSeat: pricePerSeat,
      driverId: driverId,
    );

    if (!context.mounted) return;

    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<FavoriteProvider, bool>(
      (provider) => provider.isFavorite(tripId),
    );

    return IconButton(
      onPressed: () => _toggle(context),
      tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
      iconSize: size,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          key: ValueKey<bool>(isFavorite),
          color: isFavorite ? Colors.red : Colors.grey,
        ),
      ),
    );
  }
}
