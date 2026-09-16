import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/route.dart';
import '../providers/map_provider.dart';

class RouteMap extends ConsumerStatefulWidget {
  final LatLng? origin;
  final LatLng destination;

  final bool showCurrentLocation;
  final bool followUser;

  final double initialZoom;

  const RouteMap({
    super.key,
    this.origin,
    required this.destination,
    this.showCurrentLocation = true,
    this.followUser = true,
    this.initialZoom = 15,
  });

  @override
  ConsumerState<RouteMap> createState() =>
      _RouteMapState();
}

class _RouteMapState
    extends ConsumerState<RouteMap> {
  GoogleMapController? _mapController;

  StreamSubscription<Position>?
  _positionSubscription;

  Position? _currentPosition;

  final Set<Marker> _markers =
  <Marker>{};

  final Set<Polyline> _polylines =
  <Polyline>{};

  RouteEntity? _route;

  bool _locationLoading = true;
  bool _routeLoading = false;

  String? _locationError;
  String? _routeError;

  bool _isMapReady = false;
  bool _cameraMovedToInitialLocation =
  false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _initialize();
    });
  }

  @override
  void didUpdateWidget(
      covariant RouteMap oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    final originChanged =
        oldWidget.origin != widget.origin;

    final destinationChanged =
        oldWidget.destination !=
            widget.destination;

    if (originChanged ||
        destinationChanged) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        _refreshRoute();
      });
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();

    super.dispose();
  }

  Future<void> _initialize() async {
    _setStaticMarkers();

    if (widget.origin != null) {
      await _loadRoute();
    }

    if (widget.showCurrentLocation) {
      await _startLocationTracking();
    } else {
      if (!mounted) return;

      setState(() {
        _locationLoading = false;
      });

      _fitRouteCamera();
    }
  }

  void _setStaticMarkers() {
    final markers = <Marker>{
      Marker(
        markerId:
        const MarkerId(
          'destination',
        ),
        position: widget.destination,
        infoWindow:
        const InfoWindow(
          title: 'Destination',
        ),
      ),
    };

    final origin = widget.origin;

    if (origin != null) {
      markers.add(
        Marker(
          markerId:
          const MarkerId('origin'),
          position: origin,
          infoWindow:
          const InfoWindow(
            title: 'Départ',
          ),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      _markers
        ..removeWhere(
              (marker) =>
          marker.markerId.value ==
              'origin' ||
              marker.markerId.value ==
                  'destination',
        )
        ..addAll(markers);
    });
  }

  Future<void> _refreshRoute() async {
    _setStaticMarkers();

    if (widget.origin == null) {
      if (!mounted) return;

      setState(() {
        _route = null;
        _routeError = null;
        _polylines.clear();
      });

      return;
    }

    await _loadRoute();
  }

  Future<void> _loadRoute() async {
    final origin = widget.origin;

    if (origin == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _routeLoading = true;
      _routeError = null;
    });

    try {
      final route =
      await ref.read(
        getRouteProvider,
      )(
        originLatitude:
        origin.latitude,
        originLongitude:
        origin.longitude,
        destinationLatitude:
        widget.destination.latitude,
        destinationLongitude:
        widget.destination.longitude,
      );

      if (!mounted) return;

      setState(() {
        _route = route;

        _polylines
          ..clear()
          ..add(
            Polyline(
              polylineId:
              const PolylineId(
                'route',
              ),
              points: route.points,
              width: 6,
              geodesic: true,
            ),
          );

        _routeLoading = false;
      });

      await _fitRouteCamera();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _routeLoading = false;
        _routeError =
        'Impossible de calculer '
            'l\'itinéraire.';
      });
    }
  }

  Future<void> _startLocationTracking() async {
    try {
      final serviceEnabled =
      await Geolocator
          .isLocationServiceEnabled();

      if (!serviceEnabled) {
        _setLocationError(
          'Le service de localisation '
              'est désactivé.',
        );

        return;
      }

      var permission =
      await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
        await Geolocator
            .requestPermission();
      }

      if (permission ==
          LocationPermission.denied) {
        _setLocationError(
          'Permission de localisation '
              'refusée.',
        );

        return;
      }

      if (permission ==
          LocationPermission.deniedForever) {
        _setLocationError(
          'Permission de localisation '
              'définitivement refusée.',
        );

        return;
      }

      final position =
      await Geolocator
          .getCurrentPosition(
        locationSettings:
        const LocationSettings(
          accuracy:
          LocationAccuracy.high,
        ),
      );

      _updateCurrentPosition(
        position,
        moveCamera: true,
      );

      _positionSubscription =
          Geolocator
              .getPositionStream(
            locationSettings:
            const LocationSettings(
              accuracy:
              LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen(
                (position) {
              _updateCurrentPosition(
                position,
              );
            },
            onError: (_) {
              _setLocationError(
                'Erreur de suivi GPS.',
              );
            },
          );

      if (!mounted) return;

      setState(() {
        _locationLoading = false;
      });
    } catch (_) {
      _setLocationError(
        'Impossible de récupérer '
            'votre position.',
      );
    }
  }

  void _setLocationError(
      String message,
      ) {
    if (!mounted) return;

    setState(() {
      _locationLoading = false;
      _locationError = message;
    });
  }

  void _updateCurrentPosition(
      Position position, {
        bool moveCamera = false,
      }) {
    if (!mounted) return;

    final latLng = LatLng(
      position.latitude,
      position.longitude,
    );

    setState(() {
      _currentPosition = position;

      _markers
        ..removeWhere(
              (marker) =>
          marker.markerId.value ==
              'current_user',
        )
        ..add(
          Marker(
            markerId:
            const MarkerId(
              'current_user',
            ),
            position: latLng,
            infoWindow:
            const InfoWindow(
              title: 'Ma position',
            ),
          ),
        );
    });

    if (widget.followUser ||
        moveCamera) {
      _moveCameraToUser(position);
    }
  }

  Future<void> _moveCameraToUser(
      Position position,
      ) async {
    final controller =
        _mapController;

    if (controller == null) {
      return;
    }

    try {
      await controller.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            position.latitude,
            position.longitude,
          ),
        ),
      );
    } catch (_) {
      // La carte peut être détruite
      // pendant une animation.
    }
  }

  Future<void> _onMapCreated(
      GoogleMapController controller,
      ) async {
    _mapController = controller;
    _isMapReady = true;

    if (_currentPosition != null) {
      await _moveCameraToUser(
        _currentPosition!,
      );

      return;
    }

    await _fitRouteCamera();
  }

  Future<void> _fitRouteCamera() async {
    if (!_isMapReady) {
      return;
    }

    final controller =
        _mapController;

    if (controller == null) {
      return;
    }

    final points = <LatLng>[];

    final routePoints =
        _route?.points;

    if (routePoints != null &&
        routePoints.isNotEmpty) {
      points.addAll(routePoints);
    } else {
      final origin = widget.origin;

      if (origin != null) {
        points.add(origin);
      }

      points.add(
        widget.destination,
      );
    }

    if (points.length < 2) {
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points.skip(1)) {
      if (point.latitude < minLat) {
        minLat = point.latitude;
      }

      if (point.latitude > maxLat) {
        maxLat = point.latitude;
      }

      if (point.longitude < minLng) {
        minLng = point.longitude;
      }

      if (point.longitude > maxLng) {
        maxLng = point.longitude;
      }
    }

    final bounds =
    LatLngBounds(
      southwest: LatLng(
        minLat,
        minLng,
      ),
      northeast: LatLng(
        maxLat,
        maxLng,
      ),
    );

    try {
      await controller
          .animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          80,
        ),
      );

      _cameraMovedToInitialLocation =
      true;
    } catch (_) {
      // La carte peut ne pas encore
      // avoir une taille valide.
    }
  }

  void _centerOnUser() {
    final position =
        _currentPosition;

    if (position == null) {
      return;
    }

    _moveCameraToUser(position);
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition:
          CameraPosition(
            target: widget.destination,
            zoom: widget.initialZoom,
          ),
          onMapCreated:
          _onMapCreated,
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
          mapToolbarEnabled: false,
          mapType: MapType.normal,
          buildingsEnabled: true,
          trafficEnabled: false,
        ),

        if (_routeLoading)
          _LoadingCard(
            text:
            'Calcul de l\'itinéraire...',
          ),

        if (_locationLoading)
          _LoadingCard(
            text:
            'Recherche de votre position...',
            top: _routeLoading
                ? 72
                : 16,
          ),

        if (_routeError != null)
          _ErrorCard(
            message: _routeError!,
            top: _routeLoading
                ? 72
                : 16,
          ),

        if (_locationError != null)
          _ErrorCard(
            message: _locationError!,
            top: 16,
          ),

        if (_route != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _RouteInfoCard(
              route: _route!,
            ),
          ),

        Positioned(
          right: 16,
          bottom:
          _route != null
              ? 120
              : 16,
          child:
          FloatingActionButton.small(
            heroTag:
            'route_map_location',
            onPressed:
            _centerOnUser,
            child: const Icon(
              Icons.my_location,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final String text;
  final double top;

  const _LoadingCard({
    required this.text,
    this.top = 16,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4,
        child: Padding(
          padding:
          const EdgeInsets.all(12),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Text(text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final double top;

  const _ErrorCard({
    required this.message,
    this.top = 16,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4,
        child: Padding(
          padding:
          const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  message,
                  style:
                  const TextStyle(
                    color: Colors.red,
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

class _RouteInfoCard
    extends StatelessWidget {
  final RouteEntity route;

  const _RouteInfoCard({
    required this.route,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Card(
      elevation: 6,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.route,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Text(
                    route.formattedDistance,
                    style:
                    Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  Text(
                    route.formattedDuration,
                    style:
                    Theme.of(context)
                        .textTheme
                        .bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}