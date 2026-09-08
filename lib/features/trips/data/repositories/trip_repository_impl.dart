import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trips_remote_datasource.dart';
import '../models/trip_model.dart';

class TripRepositoryImpl implements TripRepository {
  final TripsRemoteDataSource remoteDataSource;

  TripRepositoryImpl(this.remoteDataSource);

  @override
  Future<Trip> publishTrip(Trip trip) async {
    final tripModel = TripModel(
      id: trip.id,
      driverId: trip.driverId,
      departureLocation: trip.departureLocation,
      departureLabel: trip.departureLabel,
      universityId: trip.universityId,
      departureDateTime: trip.departureDateTime,
      availableSeats: trip.availableSeats,
      pricePerSeat: trip.pricePerSeat,
      status: trip.status,
      passengerIds: trip.passengerIds,
    );

    return remoteDataSource.publishTrip(tripModel);
  }

  @override
  Future<List<Trip>> searchTrips({
    required String departureLabel,
    required String universityId,
    required DateTime date,
  }) {
    return remoteDataSource.searchTrips(
      departureLabel: departureLabel,
      universityId: universityId,
      date: date,
    );
  }

  @override
  Future<List<Trip>> getTripHistory(String userId) {
    return remoteDataSource.getTripHistory(userId);
  }

  @override
  Future<void> cancelTrip(String tripId) {
    return remoteDataSource.cancelTrip(tripId);
  }
}
