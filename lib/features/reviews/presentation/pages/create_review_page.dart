import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/review_provider.dart';
import '../widgets/rating_stars.dart';

/// Formulaire d'évaluation d'un trajet.
///
/// Nécessite un [ReviewProvider] fourni plus haut dans l'arbre (voir
/// app_router.dart) ainsi que les identifiants du trajet évalué. Ces
/// identifiants viendront de l'écran "Historique des trajets" / "Mes
/// réservations" une fois ces modules branchés à Firestore ; en
/// attendant, l'écran gère aussi le cas où ils sont absents.
class CreateReviewPage extends StatefulWidget {
  final String tripId;
  final String bookingId;
  final String reviewerId;
  final String reviewedUserId;
  final String universityId;

  const CreateReviewPage({
    super.key,
    required this.tripId,
    required this.bookingId,
    required this.reviewerId,
    required this.reviewedUserId,
    required this.universityId,
  });

  @override
  State<CreateReviewPage> createState() => _CreateReviewPageState();
}

class _CreateReviewPageState extends State<CreateReviewPage> {
  int punctuality = 0;
  int driving = 0;
  int atmosphere = 0;
  int overall = 0;

  final TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Widget ratingField({
    required String title,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        RatingStars(value: value, onChanged: onChanged),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Évaluer le trajet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ratingField(
              title: 'Ponctualité du conducteur',
              value: punctuality,
              onChanged: (value) => setState(() => punctuality = value),
            ),
            const SizedBox(height: 16),
            ratingField(
              title: 'Qualité de la conduite',
              value: driving,
              onChanged: (value) => setState(() => driving = value),
            ),
            const SizedBox(height: 16),
            ratingField(
              title: 'Ambiance pendant le covoiturage',
              value: atmosphere,
              onChanged: (value) => setState(() => atmosphere = value),
            ),
            const SizedBox(height: 16),
            ratingField(
              title: 'Satisfaction globale',
              value: overall,
              onChanged: (value) => setState(() => overall = value),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Commentaire',
                hintText: 'Votre avis sur le trajet...',
                border: OutlineInputBorder(),
              ),
            ),
            if (reviewProvider.submitError != null) ...[
              const SizedBox(height: 12),
              Text(
                reviewProvider.submitError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: reviewProvider.isSubmitting ? null : _submit,
                child: reviewProvider.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Publier mon évaluation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (punctuality == 0 || driving == 0 || atmosphere == 0 || overall == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez noter tous les critères.')),
      );
      return;
    }

    final reviewProvider = context.read<ReviewProvider>();
    final success = await reviewProvider.submitReview(
      tripId: widget.tripId,
      bookingId: widget.bookingId,
      reviewerId: widget.reviewerId,
      reviewedUserId: widget.reviewedUserId,
      universityId: widget.universityId,
      punctualityRating: punctuality,
      drivingRating: driving,
      atmosphereRating: atmosphere,
      overallRating: overall,
      comment: commentController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci, votre évaluation a été publiée.')),
      );
      Navigator.of(context).pop();
    }
  }
}
