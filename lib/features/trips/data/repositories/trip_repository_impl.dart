// Implémentation concrète de TripRepository.
import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_datasource.dart';
import '../models/trip_model.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl(this.remoteDataSource);

  @override
  Future<TripEntity> publishTrip(TripEntity trip) async {
    final id = trip.id.isNotEmpty ? trip.id : remoteDataSource.newTripId();

    final model = TripModel.fromEntity(trip.copyWith(id: id));
    await remoteDataSource.createTrip(model);
    return model;
  }

  @override
  Future<void> updateTrip(TripEntity trip) {
    final model = TripModel.fromEntity(trip);
    return remoteDataSource.updateTrip(model);
  }

  @override
  Stream<List<TripEntity>> getTripHistory(String driverId) {
    return remoteDataSource.getTripHistory(driverId);
  }

  @override
  Stream<List<TripEntity>> getAllTrips() {
    return remoteDataSource.getAllTrips();
  }
}
