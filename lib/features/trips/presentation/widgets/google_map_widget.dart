import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWidget extends StatelessWidget {
  final LatLng departure;
  final LatLng arrival;

  const GoogleMapWidget({
    super.key,
    required this.departure,
    required this.arrival,
  });

  @override
  Widget build(BuildContext context) {
    final markers = {
      Marker(
        markerId:
            const MarkerId('departure'),
        position: departure,
        infoWindow: const InfoWindow(
          title: 'Départ',
        ),
      ),
      Marker(
        markerId:
            const MarkerId('arrival'),
        position: arrival,
        infoWindow: const InfoWindow(
          title: 'Arrivée',
        ),
      ),
    };

    final polylines = {
      Polyline(
        polylineId:
            const PolylineId('route'),
        points: [
          departure,
          arrival,
        ],
        width: 5,
      ),
    };

    return GoogleMap(
      initialCameraPosition:
          CameraPosition(
        target: departure,
        zoom: 12,
      ),
      markers: markers,
      polylines: polylines,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
    );
  }
}