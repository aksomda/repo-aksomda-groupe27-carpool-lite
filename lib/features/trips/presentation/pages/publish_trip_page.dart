import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/trip.dart';
import '../../domain/usecases/publish_trip.dart';
import '../../domain/usecases/search_trips.dart';
import '../../domain/usecases/get_trip_history.dart';
import '../../domain/usecases/cancel_trip.dart';

import '../../data/datasources/trips_remote_datasource.dart';
import '../../data/repositories/trip_repository_impl.dart';

import '../controllers/trip_controller.dart';

class PublishTripPage extends StatefulWidget {
  const PublishTripPage({super.key});

  @override
  State<PublishTripPage> createState() => _PublishTripPageState();
}

class _PublishTripPageState extends State<PublishTripPage> {
  final _formKey = GlobalKey<FormState>();

  final _departureController = TextEditingController();
  final _universityController = TextEditingController();
  final _seatsController = TextEditingController();
  final _priceController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

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
  }

  @override
  void dispose() {
    _departureController.dispose();
    _universityController.dispose();
    _seatsController.dispose();
    _priceController.dispose();
    _controller.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner une date et une heure.')));

      return;
    }

    final departureDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final trip = Trip(
      id: '',
      driverId: 'CURRENT_USER_ID',
      departureLocation: const GeoPoint(12.3714, -1.5197),
      departureLabel: _departureController.text.trim(),
      universityId: _universityController.text.trim(),
      departureDateTime: departureDateTime,
      availableSeats: int.parse(_seatsController.text),
      pricePerSeat: double.parse(_priceController.text),
      status: TripStatus.available,
    );

    await _controller.publish(trip);

    if (!mounted) {
      return;
    }

    if (_controller.errorMessage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Trajet publié avec succès !')));

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_controller.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Publier un trajet',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Proposez votre trajet à d’autres étudiants.',
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 24),

                    _buildPublishCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
    );
  }

  Widget _buildPublishCard() {
    return Container(
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
            _buildLocationField(
              controller: _departureController,
              label: 'DÉPART',
              hint: 'Votre lieu de départ',
              color: Colors.blue,
            ),

            const SizedBox(height: 14),

            _buildLocationField(
              controller: _universityController,
              label: 'ARRIVÉE',
              hint: 'Université de destination',
              color: Colors.orange,
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(child: _buildDateBox()),

                const SizedBox(width: 12),

                Expanded(child: _buildTimeBox()),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Expanded(
                  child: TextFormField(
                    controller: _seatsController,

                    keyboardType: TextInputType.number,

                    decoration: _inputDecoration('PLACES', Icons.people_outline),

                    validator: (value) {
                      final seats = int.tryParse(value ?? '');

                      if (seats == null || seats <= 0) {
                        return 'Nombre invalide';
                      }

                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: TextFormField(
                    controller: _priceController,

                    keyboardType: const TextInputType.numberWithOptions(decimal: true),

                    decoration: _inputDecoration('PRIX', Icons.payments_outlined, suffix: 'FCFA'),

                    validator: (value) {
                      final price = double.tryParse(value ?? '');

                      if (price == null || price < 0) {
                        return 'Prix invalide';
                      }

                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            ListenableBuilder(
              listenable: _controller,

              builder: (context, child) {
                return SizedBox(
                  width: double.infinity,

                  height: 56,

                  child: FilledButton.icon(
                    onPressed: _controller.isLoading ? null : _publish,

                    icon: _controller.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.add_road),

                    label: Text(
                      _controller.isLoading ? 'Publication...' : 'Publier le trajet',

                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),

                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1769E0),

                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Color color,
  }) {
    return TextFormField(
      controller: controller,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        prefixIcon: Icon(Icons.circle, size: 14, color: color),

        filled: true,

        fillColor: const Color(0xFFF2F4F7),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),

          borderSide: BorderSide.none,
        ),
      ),

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Champ obligatoire';
        }

        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {String? suffix}) {
    return InputDecoration(
      labelText: label,

      prefixIcon: Icon(icon, color: const Color(0xFF1769E0)),

      suffixText: suffix,

      filled: true,

      fillColor: const Color(0xFFF2F4F7),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),

        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildDateBox() {
    return InkWell(
      onTap: _selectDate,

      borderRadius: BorderRadius.circular(16),

      child: Container(
        height: 64,

        padding: const EdgeInsets.symmetric(horizontal: 12),

        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),

          borderRadius: BorderRadius.circular(16),
        ),

        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: Color(0xFF1769E0)),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text('DATE', style: TextStyle(fontSize: 10, color: Colors.grey)),

                  Text(
                    _selectedDate == null
                        ? 'Choisir'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBox() {
    return InkWell(
      onTap: _selectTime,

      borderRadius: BorderRadius.circular(16),

      child: Container(
        height: 64,

        padding: const EdgeInsets.symmetric(horizontal: 12),

        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),

          borderRadius: BorderRadius.circular(16),
        ),

        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF1769E0)),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text('HEURE', style: TextStyle(fontSize: 10, color: Colors.grey)),

                  Text(
                    _selectedTime == null ? 'Choisir' : _selectedTime!.format(context),

                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: 0,

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
    );
  }
}
