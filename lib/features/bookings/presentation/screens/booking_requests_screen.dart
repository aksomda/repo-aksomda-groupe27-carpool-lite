import 'package:flutter/material.dart';

import '../../domain/entities/booking_entity.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_card.dart';

class BookingRequestsScreen extends StatefulWidget {
  final BookingProvider bookingProvider;
  final String driverId;

  const BookingRequestsScreen({
    super.key,
    required this.bookingProvider,
    required this.driverId,
  });

  @override
  State<BookingRequestsScreen> createState() =>
      _BookingRequestsScreenState();
}

class _BookingRequestsScreenState
    extends State<BookingRequestsScreen> {
  @override
  void initState() {
    super.initState();

    widget.bookingProvider.listenToDriverRequests(
      driverId: widget.driverId,
    );

    widget.bookingProvider.addListener(_onProviderChanged);
  }

  void _onProviderChanged() {
    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    widget.bookingProvider.removeListener(_onProviderChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.bookingProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes de réservation'),
        centerTitle: true,
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(BookingProvider provider) {
    if (provider.errorMessage != null &&
        provider.driverRequests.isEmpty) {
      return _ErrorView(
        message: provider.errorMessage!,
        onRetry: () {
          provider.listenToDriverRequests(
            driverId: widget.driverId,
          );
        },
      );
    }

    if (provider.driverRequests.isEmpty) {
      return const _EmptyRequestsView();
    }

    return RefreshIndicator(
      onRefresh: () async {
        provider.listenToDriverRequests(
          driverId: widget.driverId,
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.driverRequests.length,
        itemBuilder: (context, index) {
          final request = provider.driverRequests[index];

          return BookingCard.fromRequest(
            request: request,
            onConfirm: request.status == BookingStatus.pending
                ? () => _confirmRequest(request.id)
                : null,
            onReject: request.status == BookingStatus.pending
                ? () => _rejectRequest(request.id)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _confirmRequest(String requestId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer la réservation ?'),
          content: const Text(
            'Voulez-vous accepter cette demande de réservation ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Non'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Accepter'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await widget.bookingProvider.confirmBooking(
      requestId: requestId,
    );

    if (!mounted) return;

    final message = widget.bookingProvider.errorMessage ??
        widget.bookingProvider.successMessage;

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    final rejected = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Refuser la demande ?'),
          content: const Text(
            'Voulez-vous vraiment refuser cette demande ? '
            'La place sera remise à disposition.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Non'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Refuser'),
            ),
          ],
        );
      },
    );

    if (rejected != true) return;

    await widget.bookingProvider.rejectBookingRequest(
      requestId: requestId,
    );

    if (!mounted) return;

    final message = widget.bookingProvider.errorMessage ??
        widget.bookingProvider.successMessage;

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }
}

class _EmptyRequestsView extends StatelessWidget {
  const _EmptyRequestsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune demande',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous n’avez aucune demande de réservation pour le moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}