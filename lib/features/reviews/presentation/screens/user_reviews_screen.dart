import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/review_provider.dart';
import '../widgets/rating_stars.dart';

/// Liste des avis reçus par l'utilisateur connecté, en tant que
/// conducteur. Nécessite un [ReviewProvider] fourni plus haut dans
/// l'arbre (voir app_router.dart).
class UserReviewsScreen extends StatefulWidget {
  final String userId;

  const UserReviewsScreen({super.key, required this.userId});

  @override
  State<UserReviewsScreen> createState() => _UserReviewsScreenState();
}

class _UserReviewsScreenState extends State<UserReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadReviewsForUser(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes évaluations')),
      body: Builder(
        builder: (context) {
          if (reviewProvider.isLoadingReviews) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reviewProvider.loadError != null) {
            return Center(child: Text(reviewProvider.loadError!));
          }

          final reviews = reviewProvider.receivedReviews;

          if (reviews.isEmpty) {
            return const Center(child: Text('Vous n\'avez pas encore reçu d\'évaluation.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: RatingStars(value: review.overallRating, size: 20),
                subtitle: review.comment == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(review.comment!),
                      ),
                trailing: Text('${review.averageRating.toStringAsFixed(1)} / 10'),
              );
            },
          );
        },
      ),
    );
  }
}
