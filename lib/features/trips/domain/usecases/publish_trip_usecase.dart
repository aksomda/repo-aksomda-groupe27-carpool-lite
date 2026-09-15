import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class PublishTripUseCase {
  final TripRepository repository;

  PublishTripUseCase(this.repository);

  Future<TripEntity> call({
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
    return repository.publishTrip(
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
}