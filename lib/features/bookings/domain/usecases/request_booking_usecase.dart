import '../entities/ride_request_entity.dart';
import '../repositories/booking_repository.dart';

class RequestBookingUseCase {
  final BookingRepository repository;

  RequestBookingUseCase(this.repository);

  Future<RideRequestEntity> call({
    required String tripId,
    required String passengerId,
    required String driverId,
    required int numberOfSeats,
    required double totalPrice,
  }) {
    return repository.requestBooking(
      tripId: tripId,
      passengerId: passengerId,
      driverId: driverId,
      numberOfSeats: numberOfSeats,
      totalPrice: totalPrice,
    );
  }
}