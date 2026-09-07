import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/utils/coordinate_parser.dart';
import '../../data/models/university_model.dart';

/// Écran de détail d'une université : affiche toutes les informations
/// enregistrées et sa position sur une carte Google Maps.
class UniversityDetailPage extends StatelessWidget {
  const UniversityDetailPage({super.key, required this.university});

  final UniversityModel university;

  @override
  Widget build(BuildContext context) {
    final latitude = parseCoordinate(university.latitude);
    final longitude = parseCoordinate(university.longitude);
    final hasValidPosition = latitude != null && longitude != null;

    return Scaffold(
      appBar: AppBar(title: Text(university.name)),
      body: ListView(
        children: [
          if (hasValidPosition)
            SizedBox(
              height: 260,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(latitude, longitude),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(university.id),
                    position: LatLng(latitude, longitude),
                    infoWindow: InfoWindow(
                      title: university.name,
                      snippet: university.address,
                    ),
                  ),
                },
                zoomControlsEnabled: true,
                myLocationButtonEnabled: false,
              ),
            )
          else
            Container(
              height: 160,
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              child: const Text(
                "Coordonnées invalides : impossible d'afficher la carte.\n"
                "Format attendu : ex. 12,3714° N / -1,5197° O",
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(icon: Icons.school, label: 'Nom', value: university.name),
                _DetailRow(icon: Icons.location_city, label: 'Ville', value: university.city),
                _DetailRow(icon: Icons.place, label: 'Adresse', value: university.address),
                _DetailRow(icon: Icons.explore, label: 'Latitude', value: university.latitude),
                _DetailRow(icon: Icons.explore_outlined, label: 'Longitude', value: university.longitude),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '—' : value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
