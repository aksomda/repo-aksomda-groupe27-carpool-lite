import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_status.dart';
import '../datasources/formation_local_datasource.dart';
import '../datasources/formation_remote_datasource.dart';
import '../models/formation_model.dart';

class FormationRepository {
  FormationRepository._internal() {
    if (FirebaseStatus.available) {
      _remote = FormationRemoteDataSource(firestore: FirebaseFirestore.instance);
    }
  }

  static final FormationRepository instance = FormationRepository._internal();

  FormationRemoteDataSource? _remote;
  final FormationLocalDataSource _local = FormationLocalDataSource.instance;

  Stream<List<FormationModel>> getFormations() {
    return _remote != null ? _remote!.getFormations() : _local.getFormations();
  }

  Future<void> createFormation(FormationModel formation) async {
    if (_remote != null) {
      await _remote!.createFormation(formation);
    } else {
      await _local.createFormation(formation);
    }
  }

  Future<void> updateFormation(FormationModel formation) async {
    if (_remote != null) {
      await _remote!.updateFormation(formation);
    } else {
      await _local.updateFormation(formation);
    }
  }

  Future<void> softDeleteFormation(String id) async {
    if (_remote != null) {
      await _remote!.softDeleteFormation(id);
    } else {
      await _local.softDeleteFormation(id);
    }
  }
}
