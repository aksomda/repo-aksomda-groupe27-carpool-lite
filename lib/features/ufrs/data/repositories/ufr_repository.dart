import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_status.dart';
import '../datasources/ufr_local_datasource.dart';
import '../datasources/ufr_remote_datasource.dart';
import '../models/ufr_model.dart';

class UfrRepository {
  UfrRepository._internal() {
    if (FirebaseStatus.available) {
      _remote = UfrRemoteDataSource(firestore: FirebaseFirestore.instance);
    }
  }

  static final UfrRepository instance = UfrRepository._internal();

  UfrRemoteDataSource? _remote;
  final UfrLocalDataSource _local = UfrLocalDataSource.instance;

  Stream<List<UfrModel>> getUfrs() {
    return _remote != null ? _remote!.getUfrs() : _local.getUfrs();
  }

  Future<void> createUfr(UfrModel ufr) async {
    if (_remote != null) {
      await _remote!.createUfr(ufr);
    } else {
      await _local.createUfr(ufr);
    }
  }

  Future<void> updateUfr(UfrModel ufr) async {
    if (_remote != null) {
      await _remote!.updateUfr(ufr);
    } else {
      await _local.updateUfr(ufr);
    }
  }

  Future<void> softDeleteUfr(String id) async {
    if (_remote != null) {
      await _remote!.softDeleteUfr(id);
    } else {
      await _local.softDeleteUfr(id);
    }
  }
}
