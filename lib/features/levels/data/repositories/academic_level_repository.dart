import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_status.dart';
import '../datasources/academic_level_local_datasource.dart';
import '../datasources/academic_level_remote_datasource.dart';
import '../models/academic_level_model.dart';

class AcademicLevelRepository {
  AcademicLevelRepository._internal() {
    if (FirebaseStatus.available) {
      _remote = AcademicLevelRemoteDataSource(firestore: FirebaseFirestore.instance);
    }
  }

  static final AcademicLevelRepository instance = AcademicLevelRepository._internal();

  AcademicLevelRemoteDataSource? _remote;
  final AcademicLevelLocalDataSource _local = AcademicLevelLocalDataSource.instance;

  Stream<List<AcademicLevelModel>> getLevels() {
    return _remote != null ? _remote!.getLevels() : _local.getLevels();
  }

  Future<void> createLevel(AcademicLevelModel level) async {
    if (_remote != null) {
      await _remote!.createLevel(level);
    } else {
      await _local.createLevel(level);
    }
  }

  Future<void> updateLevel(AcademicLevelModel level) async {
    if (_remote != null) {
      await _remote!.updateLevel(level);
    } else {
      await _local.updateLevel(level);
    }
  }

  Future<void> softDeleteLevel(String id) async {
    if (_remote != null) {
      await _remote!.softDeleteLevel(id);
    } else {
      await _local.softDeleteLevel(id);
    }
  }
}
