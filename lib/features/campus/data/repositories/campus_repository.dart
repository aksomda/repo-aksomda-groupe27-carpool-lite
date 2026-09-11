import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_status.dart';
import '../datasources/campus_local_datasource.dart';
import '../datasources/campus_remote_datasource.dart';
import '../models/campus_model.dart';

class CampusRepository {
  CampusRepository._internal() {
    if (FirebaseStatus.available) {
      _remote = CampusRemoteDataSource(firestore: FirebaseFirestore.instance);
    }
  }

  static final CampusRepository instance = CampusRepository._internal();

  CampusRemoteDataSource? _remote;
  final CampusLocalDataSource _local = CampusLocalDataSource.instance;

  Stream<List<CampusModel>> getCampuses() {
    return _remote != null ? _remote!.getCampuses() : _local.getCampuses();
  }

  Future<void> createCampus(CampusModel campus) async {
    if (_remote != null) {
      await _remote!.createCampus(campus);
    } else {
      await _local.createCampus(campus);
    }
  }

  Future<void> updateCampus(CampusModel campus) async {
    if (_remote != null) {
      await _remote!.updateCampus(campus);
    } else {
      await _local.updateCampus(campus);
    }
  }

  Future<void> softDeleteCampus(String id) async {
    if (_remote != null) {
      await _remote!.softDeleteCampus(id);
    } else {
      await _local.softDeleteCampus(id);
    }
  }
}
