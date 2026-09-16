import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_datasource.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<TripEntity> publishTrip({
    required String driverId,
    required String departure,
    required String arrival,
    required double departureLatitude,
    required double departureLongitude,
    required double arrivalLatitude,
    required double arrivalLongitude,
    required DateTime departureDateTime,
    required double pricePerSeat,
    required int totalSeats,
  }) {
    return remoteDataSource.publishTrip(
      driverId: driverId,
      departure: departure,
      arrival: arrival,
      departureLatitude: departureLatitude,
      departureLongitude: departureLongitude,
      arrivalLatitude: arrivalLatitude,
      arrivalLongitude: arrivalLongitude,
      departureDateTime: departureDateTime,
      pricePerSeat: pricePerSeat,
      totalSeats: totalSeats,
    );
  }

  @override
  Stream<List<TripEntity>> searchTrips({
    String? departure,
    String? arrival,
    DateTime? date,
  }) {
    return remoteDataSource.searchTrips(
      departure: departure,
      arrival: arrival,
      date: date,
    );
  }

  @override
  Future<TripEntity?> getTripById(
    String tripId,
  ) {
    return remoteDataSource.getTripById(
      tripId,
    );
  }

  @override
  Future<TripEntity> updateAvailableSeats({
    required String tripId,
    required int delta,
  }) {
    return remoteDataSource.updateAvailableSeats(
      tripId: tripId,
      delta: delta,
    );
  }

  @override
  Stream<List<TripEntity>> getTripHistory({
    required String driverId,
  }) {
    return remoteDataSource.getTripHistory(
      driverId: driverId,
    );
  }
}