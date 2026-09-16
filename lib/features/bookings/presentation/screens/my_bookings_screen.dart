import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../navigation/presentation/widgets/app_drawer.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_card.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/ride_request_entity.dart';

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

    widget.bookingProvider.listenToUserRequests(
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
    final bookings = provider.userBookings;
    // Demandes pas encore acceptées ("en attente") ou refusées : une
    // demande confirmée est déjà représentée par une BookingEntity
    // ci-dessus, donc pas de doublon.
    final pendingRequests = provider.userPendingRequests;

    final isEmpty = bookings.isEmpty && pendingRequests.isEmpty;

    if (provider.errorMessage != null && isEmpty) {
      return _ErrorView(
        message: provider.errorMessage!,
        onRetry: () => _refresh(provider),
      );
    }

    if (isEmpty) {
      return const _EmptyBookingsView();
    }

    final items = <_BookingListItem>[
      ...bookings.map(_BookingListItem.booking),
      ...pendingRequests.map(_BookingListItem.request),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return RefreshIndicator(
      onRefresh: () async => _refresh(provider),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final booking = item.booking;

          if (booking != null) {
            return BookingCard.fromBooking(
              booking: booking,
              onCancel: booking.status == BookingStatus.confirmed
                  ? () => _cancelBooking(booking.id, booking.tripId)
                  : null,
            );
          }

          return BookingCard.fromRequest(request: item.request!);
        },
      ),
    );
  }

  void _refresh(BookingProvider provider) {
    provider.listenToUserBookings(
      passengerId: widget.passengerId,
    );

    provider.listenToUserRequests(
      passengerId: widget.passengerId,
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

/// Élément d'affichage unifié pour "Mes réservations" : soit une
/// réservation confirmée (BookingEntity), soit une demande pas encore
/// traitée ou refusée (RideRequestEntity), triées ensemble par date.
class _BookingListItem {
  final BookingEntity? booking;
  final RideRequestEntity? request;

  const _BookingListItem._({this.booking, this.request});

  factory _BookingListItem.booking(BookingEntity booking) {
    return _BookingListItem._(booking: booking);
  }

  factory _BookingListItem.request(RideRequestEntity request) {
    return _BookingListItem._(request: request);
  }

  DateTime get date => booking?.reservationDate ?? request!.createdAt;
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