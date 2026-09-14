import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/trip.dart';
import '../../domain/usecases/cancel_trip.dart';
import '../../domain/usecases/get_trip_history.dart';
import '../../domain/usecases/publish_trip.dart';
import '../../domain/usecases/search_trips.dart';

import '../../data/datasources/trips_remote_datasource.dart';
import '../../data/repositories/trip_repository_impl.dart';

import '../controllers/trip_controller.dart';

class SearchTripsPage extends StatefulWidget {
  const SearchTripsPage({super.key});

  @override
  State<SearchTripsPage> createState() => _SearchTripsPageState();
}

class _SearchTripsPageState extends State<SearchTripsPage> {
  final _formKey = GlobalKey<FormState>();

  final _departureController = TextEditingController();
  final _universityController = TextEditingController();

  DateTime? _selectedDate;

  bool _hasSearched = false;

  int _passengers = 1;

  late final TripController _controller;

  @override
  void initState() {
    super.initState();

    final firestore = FirebaseFirestore.instance;

    final remoteDataSource = TripsRemoteDataSource(firestore);

    final repository = TripRepositoryImpl(remoteDataSource);

    _controller = TripController(
      publishTrip: PublishTrip(repository),
      searchTrips: SearchTrips(repository),
      getTripHistory: GetTripHistory(repository),
      cancelTrip: CancelTrip(repository),
    );

    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _departureController.dispose();
    _universityController.dispose();

    _controller.removeListener(_onControllerChanged);

    _controller.dispose();

    super.dispose();
  }

  // =========================
  // DATE
  // =========================

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  // =========================
  // PASSAGERS
  // =========================

  Future<void> _selectPassengers() async {
    int temporaryPassengers = _passengers;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Nombre de passagers',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: temporaryPassengers > 1
                              ? () {
                                  setModalState(() {
                                    temporaryPassengers--;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.remove_circle_outline, size: 36),
                        ),

                        const SizedBox(width: 24),

                        Text(
                          '$temporaryPassengers',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(width: 24),

                        IconButton(
                          onPressed: () {
                            setModalState(() {
                              temporaryPassengers++;
                            });
                          },
                          icon: const Icon(
                            Icons.add_circle_outline,
                            size: 36,
                            color: Color(0xFF1769E0),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _passengers = temporaryPassengers;
                          });

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1769E0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Confirmer',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =========================
  // RECHERCHE
  // =========================

  Future<void> _search() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner une date.')));

      return;
    }

    setState(() {
      _hasSearched = true;
    });

    await _controller.search(
      departureLabel: _departureController.text.trim(),
      universityId: _universityController.text.trim(),
      date: _selectedDate!,
    );

    if (!mounted) {
      return;
    }

    if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_controller.errorMessage!)));
    }
  }

  // =========================
  // PAGE
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: SizedBox(
                height: 90,
                child: Row(
                  children: [
                    SizedBox(
                      width: 125,
                      child: Image.asset('assets/images/carpool_logo.png', fit: BoxFit.contain),
                    ),

                    const Spacer(),

                    const Icon(Icons.notifications_none, size: 28),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSearchSection(),

                    const SizedBox(height: 28),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildResults(),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          if (index == 0) {
            context.go('/trips/publish');
          } else if (index == 1) {
            context.go('/trips/search');
          } else if (index == 2) {
            context.go('/trips/history');
          }
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Publier'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Rechercher'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
        ],
      ),
    );
  }

  // =========================
  // SECTION RECHERCHE
  // =========================

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Form(
        key: _formKey,

        child: Column(
          children: [
            // DEPART
            TextFormField(
              controller: _departureController,
              decoration: InputDecoration(
                labelText: 'DÉPART',
                hintText: 'Ex : Université Joseph KI-ZERBO',

                prefixIcon: const Icon(Icons.circle, size: 14, color: Colors.blue),

                filled: true,

                fillColor: const Color(0xFFF2F4F7),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez saisir le lieu de départ.';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            // ARRIVEE
            TextFormField(
              controller: _universityController,

              decoration: InputDecoration(
                labelText: 'ARRIVÉE',

                hintText: 'Ex : Université Joseph KI-ZERBO',

                prefixIcon: const Icon(Icons.circle, size: 14, color: Colors.orange),

                filled: true,

                fillColor: const Color(0xFFF2F4F7),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez saisir l’université.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // DATE + PASSAGERS
            Row(
              children: [
                Expanded(
                  flex: 2,

                  child: OutlinedButton.icon(
                    onPressed: _selectDate,

                    icon: const Icon(Icons.calendar_month),

                    label: Text(
                      _selectedDate == null
                          ? 'Aujourd’hui'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      overflow: TextOverflow.ellipsis,
                    ),

                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 58),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // PASSAGERS
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),

                    onTap: _selectPassengers,

                    child: Container(
                      height: 58,

                      padding: const EdgeInsets.symmetric(horizontal: 10),

                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),

                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Row(
                        children: [
                          const Icon(Icons.people_outline, color: Color(0xFF1769E0), size: 21),

                          const SizedBox(width: 7),

                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,

                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  'PASSAGERS',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                Text(
                                  '$_passengers',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // BOUTON RECHERCHER
            SizedBox(
              width: double.infinity,
              height: 54,

              child: FilledButton.icon(
                onPressed: _controller.isLoading ? null : _search,

                icon: const Icon(Icons.search),

                label: const Text(
                  'Rechercher un trajet',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),

                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1769E0),

                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // RESULTATS
  // =========================

  Widget _buildResults() {
    if (!_hasSearched) {
      return const SizedBox.shrink();
    }

    if (_controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),

        child: Center(child: CircularProgressIndicator()),
      );
    }

    // On garde uniquement les trajets
    // ayant assez de places.
    final availableTrips = _controller.trips
        .where((trip) => trip.availableSeats >= _passengers)
        .toList();

    if (availableTrips.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),

        child: Center(
          child: Text(
            'Aucun trajet avec assez de places.',
            textAlign: TextAlign.center,

            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'Trajets disponibles',

          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 18),

        ...availableTrips.map((trip) => _buildTripCard(trip)),
      ],
    );
  }

  // =========================
  // CARTE TRAJET
  // =========================

  Widget _buildTripCard(Trip trip) {
    final time =
        '${trip.departureDateTime.hour.toString().padLeft(2, '0')}:'
        '${trip.departureDateTime.minute.toString().padLeft(2, '0')}';

    final vehicleText = trip.vehicleId.isEmpty ? 'Véhicule non renseigné' : trip.vehicleId;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7E7E7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEAF2FF)),
            child: const Icon(Icons.person, size: 34, color: Color(0xFF1769E0)),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.departureLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text('${trip.availableSeats} place(s)', style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.directions_car_outlined, size: 20, color: Color(0xFF1769E0)),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        vehicleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        '${trip.pricePerSeat.toStringAsFixed(0)} FCFA',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1769E0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          const Icon(Icons.chevron_right, size: 28),
        ],
      ),
    );
  }
}
