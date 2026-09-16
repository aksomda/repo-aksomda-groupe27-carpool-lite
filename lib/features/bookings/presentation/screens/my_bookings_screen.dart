import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../navigation/presentation/widgets/app_drawer.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_card.dart';
import '../../domain/entities/booking_entity.dart';

class MyBookingsScreen extends StatefulWidget {
  final BookingProvider bookingProvider;
  final String passengerId;

  const MyBookingsScreen({
    super.key,
    required this.bookingProvider,
    required this.passengerId,
  });

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();

    widget.bookingProvider.listenToUserBookings(
      passengerId: widget.passengerId,
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
      drawer: AppDrawer(authProvider: Injector.authProvider),
      appBar: AppBar(
        title: const Text('Mes réservations'),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(BookingProvider provider) {
    if (provider.errorMessage != null &&
        provider.userBookings.isEmpty) {
      return _ErrorView(
        message: provider.errorMessage!,
        onRetry: () {
          provider.listenToUserBookings(
            passengerId: widget.passengerId,
          );
        },
      );
    }

    if (provider.userBookings.isEmpty) {
      return const _EmptyBookingsView();
    }

    return RefreshIndicator(
      onRefresh: () async {
        provider.listenToUserBookings(
          passengerId: widget.passengerId,
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.userBookings.length,
        itemBuilder: (context, index) {
          final booking = provider.userBookings[index];

          return BookingCard.fromBooking(
            booking: booking,
            onCancel: booking.status == BookingStatus.confirmed ||
                    booking.status == BookingStatus.pending
                ? () => _cancelBooking(booking.id, booking.tripId)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _cancelBooking(
    String bookingId,
    String tripId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Annuler la réservation ?'),
          content: const Text(
            'Voulez-vous vraiment annuler cette réservation ? '
            'La place sera remise à disposition.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Non'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Oui, annuler'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await widget.bookingProvider.cancelBooking(
      tripId: tripId,
      bookingId: bookingId,
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

class _EmptyBookingsView extends StatelessWidget {
  const _EmptyBookingsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_seat_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune réservation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous n’avez encore aucune réservation.',
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