import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_status.dart';
import '../datasources/university_local_datasource.dart';
import '../datasources/university_remote_datasource.dart';
import '../models/university_model.dart';

/// Point d'entrée unique pour la feature "universités".
///
/// Si Firebase a pu être initialisé (voir [FirebaseStatus]), les opérations
/// passent par Firestore via [UniversityRemoteDataSource]. Sinon, elles
/// passent par [UniversityLocalDataSource] (en mémoire), ce qui permet de
/// tester graphiquement les écrans sans projet Firebase configuré.
class UniversityRepository {
  UniversityRepository._internal() {
    if (FirebaseStatus.available) {
      _remote = UniversityRemoteDataSource(
        firestore: FirebaseFirestore.instance,
      );
    }
  }

  static final UniversityRepository instance =
      UniversityRepository._internal();

  UniversityRemoteDataSource? _remote;
  final UniversityLocalDataSource _local = UniversityLocalDataSource.instance;

  /// Vrai si les données proviennent de Firestore, faux si mode local.
  bool get isUsingFirestore => _remote != null;

  Stream<List<UniversityModel>> getUniversities() {
    if (_remote != null) {
      return _remote!.getUniversities();
    }
    return _local.getUniversities();
  }

  Future<void> createUniversity(UniversityModel university) async {
    if (_remote != null) {
      await _remote!.createUniversity(university);
    } else {
      await _local.createUniversity(university);
    }
  }
}
