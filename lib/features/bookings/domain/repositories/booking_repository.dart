import '../entities/ride_request_entity.dart';

abstract class BookingRepository {
  /// Crée une demande de réservation. [request.id] peut être vide : un
  /// identifiant Firestore est alors généré par l'implémentation, et la
  /// demande persistée (avec son id définitif) est retournée.
  Future<RideRequestEntity> requestBooking(RideRequestEntity request);

  /// Change le statut d'une demande (acceptation, refus, annulation).
  Future<void> updateStatus(String requestId, RideRequestStatus statut);

  /// Demandes reçues par [driverId] sur ses trajets, du plus récent au
  /// plus ancien.
  Stream<List<RideRequestEntity>> getDriverRequests(String driverId);

  /// Demandes envoyées par [passengerId], du plus récent au plus ancien.
  Stream<List<RideRequestEntity>> getMyRequests(String passengerId);
}
