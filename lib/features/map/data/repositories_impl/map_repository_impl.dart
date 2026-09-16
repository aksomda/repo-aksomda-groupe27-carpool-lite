import '../../domain/entities/route.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/google_maps_datasource.dart';
import '../models/route_model.dart';

class MapRepositoryImpl
    implements MapRepository {
  MapRepositoryImpl({
    required GoogleMapsDataSource dataSource,
  }) : _dataSource = dataSource;

  final GoogleMapsDataSource _dataSource;

  @override
  Future<RouteEntity> getRoute({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    final response =
    await _dataSource.getRoute(
      originLatitude: originLatitude,
      originLongitude: originLongitude,
      destinationLatitude:
      destinationLatitude,
      destinationLongitude:
      destinationLongitude,
    );

    return RouteModel
        .fromGoogleResponse(response)
        .toEntity();
  }
}