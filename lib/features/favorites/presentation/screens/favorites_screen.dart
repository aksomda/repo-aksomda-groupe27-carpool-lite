import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/favorite_entity.dart';
import '../providers/favorite_provider.dart';

/// Liste des trajets mis en favori par l'utilisateur connecté.
class FavoritesScreen extends StatefulWidget {
  final String userId;

  const FavoritesScreen({super.key, required this.userId});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _hideExpired = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FavoriteProvider>().loadFavorites(widget.userId);
    });
  }

  Future<void> _remove(FavoriteEntity favorite) async {
    final provider = context.read<FavoriteProvider>();

    final success = await provider.removeFavorite(
      userId: widget.userId,
      tripId: favorite.tripId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (provider.successMessage ?? 'Trajet retiré des favoris.')
              : (provider.errorMessage ?? 'Suppression impossible.'),
        ),
        backgroundColor: success ? null : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoriteProvider>();

    final favorites = _hideExpired
        ? provider.upcomingFavorites
        : provider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes favoris'),
        actions: [
          IconButton(
            tooltip: _hideExpired
                ? 'Afficher les trajets passés'
                : 'Masquer les trajets passés',
            onPressed: () => setState(() => _hideExpired = !_hideExpired),
            icon: Icon(
              _hideExpired ? Icons.history : Icons.history_toggle_off,
            ),
          ),
        ],
      ),
      body: _buildBody(provider, favorites),
    );
  }

  Widget _buildBody(
    FavoriteProvider provider,
    List<FavoriteEntity> favorites,
  ) {
    if (provider.isLoading && provider.favorites.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(provider.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => provider.loadFavorites(widget.userId),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Aucun trajet en favori',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Touchez le cœur sur un trajet pour le retrouver ici.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.go('/trips/search'),
                icon: const Icon(Icons.search),
                label: const Text('Rechercher un trajet'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Opacity(
            opacity: favorite.isExpired ? 0.6 : 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${favorite.departure} → ${favorite.arrival}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${favorite.pricePerSeat.toStringAsFixed(0)} '
                        '${AppConstants.currency}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        DateFormatter.formatDateTime(
                          favorite.departureDateTime,
                        ),
                      ),
                    ],
                  ),
                  if (favorite.isExpired) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Trajet passé',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _remove(favorite),
                        icon: const Icon(
                          Icons.favorite,
                          size: 18,
                          color: Colors.red,
                        ),
                        label: const Text('Retirer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
