import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/route.dart';

class RouteModel {
  final List<LatLng> points;
  final double distanceMeters;
  final int durationSeconds;

  const RouteModel({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  factory RouteModel.fromGoogleResponse(
      Map<String, dynamic> json,
      ) {
    final routes = json['routes'];

    if (routes is! List || routes.isEmpty) {
      throw Exception(
        'Aucun itinéraire trouvé.',
      );
    }

    final route =
    routes.first as Map<String, dynamic>;

    final encodedPolyline =
    route['polyline']
    ?['encodedPolyline'];

    if (encodedPolyline is! String ||
        encodedPolyline.isEmpty) {
      throw Exception(
        'Polyline Google absente.',
      );
    }

    final distance =
    route['distanceMeters'];

    final duration =
    route['duration'];

    return RouteModel(
      points: _decodePolyline(
        encodedPolyline,
      ),
      distanceMeters:
      distance is num
          ? distance.toDouble()
          : 0,
      durationSeconds:
      _parseDuration(duration),
    );
  }

  RouteEntity toEntity() {
    return RouteEntity(
      points: points,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
    );
  }

  static int _parseDuration(
      dynamic value,
      ) {
    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      final match =
      RegExp(r'^([\d.]+)s$')
          .firstMatch(value);

      if (match != null) {
        return double.parse(
          match.group(1)!,
        ).round();
      }
    }

    return 0;
  }

  static List<LatLng> _decodePolyline(
      String encoded,
      ) {
    final points = <LatLng>[];

    int index = 0;
    int latitude = 0;
    int longitude = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;

      while (true) {
        final byte =
            encoded.codeUnitAt(index++) -
                63;

        result |=
            (byte & 0x1F) << shift;

        shift += 5;

        if (byte < 0x20) {
          break;
        }
      }

      final latitudeDelta =
      (result & 1) != 0
          ? ~(result >> 1)
          : (result >> 1);

      latitude += latitudeDelta;

      shift = 0;
      result = 0;

      while (true) {
        final byte =
            encoded.codeUnitAt(index++) -
                63;

        result |=
            (byte & 0x1F) << shift;

        shift += 5;

        if (byte < 0x20) {
          break;
        }
      }

      final longitudeDelta =
      (result & 1) != 0
          ? ~(result >> 1)
          : (result >> 1);

      longitude += longitudeDelta;

      points.add(
        LatLng(
          latitude / 1e5,
          longitude / 1e5,
        ),
      );
    }

    return points;
  }
}