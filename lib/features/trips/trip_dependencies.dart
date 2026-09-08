import 'package:cloud_firestore/cloud_firestore.dart';

import 'data/datasources/trips_remote_datasource.dart';
import 'data/repositories/trip_repository_impl.dart';
import 'domain/repositories/trip_repository.dart';

class TripDependencies {
  static TripRepository createRepository() {
    final firestore = FirebaseFirestore.instance;

    final remoteDataSource = TripsRemoteDataSource(firestore);

    return TripRepositoryImpl(remoteDataSource);
  }
}
