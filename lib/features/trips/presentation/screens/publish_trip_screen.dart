import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/di/injector.dart';
import '../../../navigation/presentation/widgets/app_drawer.dart';
import '../providers/trip_provider.dart';

class PublishTripScreen extends StatefulWidget {
  final TripProvider tripProvider;

  const PublishTripScreen({
    super.key,
    required this.tripProvider,
  });

  @override
  State<PublishTripScreen> createState() => _PublishTripScreenState();
}

class _PublishTripScreenState extends State<PublishTripScreen> {
  final _formKey = GlobalKey<FormState>();

  final _departureController = TextEditingController();
  final _arrivalController = TextEditingController();
  final _priceController = TextEditingController();

  GoogleMapController? _mapController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  int _totalSeats = 1;

  LatLng? _departurePosition;
  LatLng? _arrivalPosition;
  LatLng? _currentPosition;

  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();

    widget.tripProvider.addListener(_onProviderChanged);
  }

  void _onProviderChanged() {
    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    widget.tripProvider.removeListener(_onProviderChanged);
    _departureController.dispose();
    _arrivalController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  TripProvider get _tripProvider => widget.tripProvider;

  // ============================================================
  // LOCALISATION
  // ============================================================

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showMessage(
          'La localisation est désactivée. Veuillez l’activer.',
        );
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          _showMessage(
            'La permission de localisation a été refusée.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage(
          'La localisation est bloquée. '
          'Autorisez-la dans les paramètres du navigateur.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final currentLatLng = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = currentLatLng;
      });

      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLatLng,
            zoom: 16,
          ),
        ),
      );

      _showMessage('Votre position a été trouvée.');
    } catch (e) {
      debugPrint('Erreur localisation : $e');

      if (!mounted) return;

      _showMessage(
        'Impossible de récupérer votre position.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  // ============================================================
  // SELECTION DEPART / ARRIVEE
  // ============================================================

  void _onMapTap(LatLng position) {
    setState(() {
      if (_departurePosition == null) {
        _departurePosition = position;

        _departureController.text =
            'Position (${position.latitude.toStringAsFixed(5)}, '
            '${position.longitude.toStringAsFixed(5)})';

        _showMessage('Point de départ sélectionné.');
      } else if (_arrivalPosition == null) {
        _arrivalPosition = position;

        _arrivalController.text =
            'Position (${position.latitude.toStringAsFixed(5)}, '
            '${position.longitude.toStringAsFixed(5)})';

        _showMessage('Point d’arrivée sélectionné.');
      } else {
        // Si les deux points existent déjà,
        // un nouveau clic recommence la sélection.
        _departurePosition = position;
        _arrivalPosition = null;

        _departureController.text =
            'Position (${position.latitude.toStringAsFixed(5)}, '
            '${position.longitude.toStringAsFixed(5)})';

        _arrivalController.clear();

        _showMessage(
          'Nouveau départ sélectionné. '
          'Sélectionnez maintenant l’arrivée.',
        );
      }
    });
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  // ============================================================
  // HEURE
  // ============================================================

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  // ============================================================
  // PUBLICATION
  // ============================================================

  Future<void> _publishTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      _showMessage(
        'Veuillez sélectionner la date et l’heure du trajet.',
      );
      return;
    }

    if (_departurePosition == null) {
      _showMessage(
        'Veuillez sélectionner le point de départ sur la carte.',
      );
      return;
    }

    if (_arrivalPosition == null) {
      _showMessage(
        'Veuillez sélectionner le point d’arrivée sur la carte.',
      );
      return;
    }

    final departureDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (!departureDateTime.isAfter(DateTime.now())) {
      _showMessage(
        'La date et l’heure du trajet doivent être dans le futur.',
      );
      return;
    }

    final price = double.tryParse(
      _priceController.text.trim(),
    );

    if (price == null) {
      _showMessage('Prix invalide.');
      return;
    }

    // ==========================================================
    // ENREGISTREMENT DU TRAJET DANS FIRESTORE
    // ==========================================================

    final driverId = Injector.authProvider.user?.uid;

    if (driverId == null || driverId.isEmpty) {
      _showMessage(
        'Vous devez être connecté pour publier un trajet.',
      );
      return;
    }

    final trip = await _tripProvider.publishTrip(
      driverId: driverId,
      departure: _departureController.text,
      arrival: _arrivalController.text,
      departureLatitude: _departurePosition!.latitude,
      departureLongitude: _departurePosition!.longitude,
      arrivalLatitude: _arrivalPosition!.latitude,
      arrivalLongitude: _arrivalPosition!.longitude,
      departureDateTime: departureDateTime,
      pricePerSeat: price,
      totalSeats: _totalSeats,
    );

    if (!mounted) return;

    final message =
        _tripProvider.errorMessage ?? _tripProvider.successMessage;

    if (message != null) {
      _showMessage(message);
    }

    if (trip != null) {
      Navigator.of(context).pop(trip);
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(authProvider: Injector.authProvider),
      appBar: AppBar(
        title: const Text("Publication d'un trajet"),
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Publier un trajet',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Proposez un trajet aux autres étudiants.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // DEPART
              // ==================================================

              TextFormField(
                controller: _departureController,
                decoration: const InputDecoration(
                  labelText: 'Lieu de départ',
                  hintText: 'Sélectionnez le départ sur la carte',
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Le lieu de départ est obligatoire.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // ARRIVEE
              // ==================================================

              TextFormField(
                controller: _arrivalController,
                decoration: const InputDecoration(
                  labelText: 'Lieu d’arrivée',
                  hintText: 'Sélectionnez l’arrivée sur la carte',
                  prefixIcon: Icon(
                    Icons.flag_outlined,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Le lieu d’arrivée est obligatoire.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // POSITION GPS
              // ==================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Position GPS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  OutlinedButton.icon(
                    onPressed: _isLoadingLocation
                        ? null
                        : _getCurrentLocation,
                    icon: _isLoadingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.my_location,
                          ),
                    label: Text(
                      _isLoadingLocation
                          ? 'Localisation...'
                          : 'Ma position',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ==================================================
              // CARTE
              // ==================================================

              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: GoogleMap(
                  initialCameraPosition:
                      const CameraPosition(
                    target: LatLng(
                      9.6412,
                      -13.5784,
                    ),
                    zoom: 12,
                  ),

                  onMapCreated:
                      (GoogleMapController controller) {
                    _mapController = controller;

                    if (_currentPosition != null) {
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: _currentPosition!,
                            zoom: 16,
                          ),
                        ),
                      );
                    }
                  },

                  myLocationEnabled:
                      _currentPosition != null,

                  myLocationButtonEnabled: false,

                  zoomControlsEnabled: true,

                  markers: {
                    if (_currentPosition != null)
                      Marker(
                        markerId:
                            const MarkerId(
                          'current_position',
                        ),
                        position:
                            _currentPosition!,
                        icon:
                            BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure,
                        ),
                        infoWindow:
                            const InfoWindow(
                          title: 'Ma position',
                        ),
                      ),

                    if (_departurePosition != null)
                      Marker(
                        markerId:
                            const MarkerId(
                          'departure',
                        ),
                        position:
                            _departurePosition!,
                        icon:
                            BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen,
                        ),
                        infoWindow:
                            const InfoWindow(
                          title: 'Départ',
                        ),
                      ),

                    if (_arrivalPosition != null)
                      Marker(
                        markerId:
                            const MarkerId(
                          'arrival',
                        ),
                        position:
                            _arrivalPosition!,
                        icon:
                            BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                        infoWindow:
                            const InfoWindow(
                          title: 'Arrivée',
                        ),
                      ),
                  },

                  onTap: _onMapTap,
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // INSTRUCTIONS
              // ==================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue
                      .withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Touchez la carte une première fois '
                        'pour sélectionner le départ, puis '
                        'une deuxième fois pour sélectionner '
                        'l’arrivée.',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // DATE + HEURE
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(
                        Icons.calendar_today,
                      ),
                      label: Text(
                        _selectedDate == null
                            ? 'Choisir une date'
                            : '${_selectedDate!.day}/'
                              '${_selectedDate!.month}/'
                              '${_selectedDate!.year}',
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectTime,
                      icon: const Icon(
                        Icons.access_time,
                      ),
                      label: Text(
                        _selectedTime == null
                            ? 'Choisir une heure'
                            : _selectedTime!
                                .format(context),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ==================================================
              // PRIX
              // ==================================================

              TextFormField(
                controller: _priceController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText: 'Prix par place',
                  hintText: 'Ex. 1500',
                  suffixText: 'GNF',
                  prefixIcon: Icon(
                    Icons.payments_outlined,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Le prix est obligatoire.';
                  }

                  final price =
                      double.tryParse(value);

                  if (price == null ||
                      price < 0) {
                    return 'Veuillez saisir un prix valide.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // PLACES
              // ==================================================

              const Text(
                'Nombre de places',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  IconButton(
                    onPressed: _totalSeats > 1
                        ? () {
                            setState(() {
                              _totalSeats--;
                            });
                          }
                        : null,
                    icon: const Icon(
                      Icons.remove_circle_outline,
                    ),
                  ),

                  Text(
                    '$_totalSeats',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  IconButton(
                    onPressed: _totalSeats < 8
                        ? () {
                            setState(() {
                              _totalSeats++;
                            });
                          }
                        : null,
                    icon: const Icon(
                      Icons.add_circle_outline,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ==================================================
              // PUBLICATION
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed:
                      _tripProvider.isPublishing ? null : _publishTrip,
                  icon: _tripProvider.isPublishing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.directions_car,
                        ),
                  label: Text(
                    _tripProvider.isPublishing
                        ? 'Publication...'
                        : 'Publier le trajet',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}