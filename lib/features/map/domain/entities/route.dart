import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteEntity {
  final List<LatLng> points;
  final double distanceMeters;
  final int durationSeconds;

  const RouteEntity({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  double get distanceKm => distanceMeters / 1000;

  Duration get duration =>
      Duration(seconds: durationSeconds);

  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    }

    return '${distanceKm.toStringAsFixed(1)} km';
  }

  String get formattedDuration {
    final duration = this.duration;

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours h ${minutes.toString().padLeft(2, '0')} min';
    }

    return '${duration.inMinutes} min';
  }
}