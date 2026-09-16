import '../entities/route.dart';

abstract class MapRepository {
  Future<RouteEntity> getRoute({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  });
}