import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/ride_request_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl
    implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<RideRequestEntity> requestBooking({
    required String tripId,
    required String passengerId,
    required String driverId,
    required int numberOfSeats,
    required double totalPrice,
  }) {
    return remoteDataSource.requestBooking(
      tripId: tripId,
      passengerId: passengerId,
      driverId: driverId,
      numberOfSeats: numberOfSeats,
      totalPrice: totalPrice,
    );
  }

  @override
  Future<BookingEntity> confirmBooking({
    required String requestId,
  }) {
    return remoteDataSource.confirmBooking(
      requestId: requestId,
    );
  }

  @override
  Future<void> rejectBookingRequest({
    required String requestId,
  }) {
    return remoteDataSource.rejectBookingRequest(
      requestId: requestId,
    );
  }

  @override
  Future<void> cancelBooking({
    required String tripId,
    required String bookingId,
  }) {
    return remoteDataSource.cancelBooking(
      tripId: tripId,
      bookingId: bookingId,
    );
  }

  @override
  Stream<List<BookingEntity>> getUserBookings({
    required String passengerId,
  }) {
    return remoteDataSource.getUserBookings(
      passengerId: passengerId,
    );
  }

  @override
  Stream<List<RideRequestEntity>>
      getDriverRequests({
    required String driverId,
  }) {
    return remoteDataSource.getDriverRequests(
      driverId: driverId,
    );
  }
}