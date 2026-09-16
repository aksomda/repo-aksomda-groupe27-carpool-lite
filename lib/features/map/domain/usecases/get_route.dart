import '../entities/route.dart';
import '../repositories/map_repository.dart';

class GetRoute {
  const GetRoute(this._repository);

  final MapRepository _repository;

  Future<RouteEntity> call({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) {
    return _repository.getRoute(
      originLatitude: originLatitude,
      originLongitude: originLongitude,
      destinationLatitude:
      destinationLatitude,
      destinationLongitude:
      destinationLongitude,
    );
  }
}