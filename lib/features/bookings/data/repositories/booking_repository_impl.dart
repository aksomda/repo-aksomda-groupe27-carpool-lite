// Implémentation concrète de BookingRepository.
import '../../domain/entities/ride_request_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';
import '../models/ride_request_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl(this.remoteDataSource);

  @override
  Future<RideRequestEntity> requestBooking(RideRequestEntity request) async {
    final id = request.id.isNotEmpty ? request.id : remoteDataSource.newRequestId();

    final model = RideRequestModel.fromEntity(request.copyWith(id: id));
    await remoteDataSource.createRequest(model);
    return model;
  }

  @override
  Future<void> updateStatus(String requestId, RideRequestStatus statut) {
    return remoteDataSource.updateStatus(requestId, statut);
  }

  @override
  Stream<List<RideRequestEntity>> getDriverRequests(String driverId) {
    return remoteDataSource.getDriverRequests(driverId);
  }

  @override
  Stream<List<RideRequestEntity>> getMyRequests(String passengerId) {
    return remoteDataSource.getMyRequests(passengerId);
  }
}
