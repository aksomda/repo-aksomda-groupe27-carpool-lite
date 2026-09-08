import 'dart:async';

import '../models/campus_model.dart';

/// Source de données locale (en mémoire) utilisée quand Firebase n'est pas
/// configuré. Gère l'ajout, la modification et la suppression logique.
class CampusLocalDataSource {
  CampusLocalDataSource._internal();

  static final CampusLocalDataSource instance =
      CampusLocalDataSource._internal();

  final List<CampusModel> _campuses = [
    const CampusModel(
      id: 'campus-demo-1',
      name: 'Campus de Zogona',
      code: 'CAMP-ZOG',
      universityId: 'demo-1',
      universityName: 'Université Joseph Ki-Zerbo',
    ),
    const CampusModel(
      id: 'campus-demo-1',
      name: 'Campus de IBAM',
      code: 'CAMP-IBAM',
      universityId: 'demo-1',
      universityName: 'Université Joseph Ki-Zerbo',
    ),
    const CampusModel(
      id: 'campus-demo-2',
      name: 'Campus de Nasso',
      code: 'CAMP-NASSO',
      universityId: 'demo-2',
      universityName: 'Université Nazi Boni',
    ),
  ];

  final StreamController<List<CampusModel>> _controller =
      StreamController<List<CampusModel>>.broadcast();

  void _emit() {
    final active = _campuses.where((c) => !c.isDeleted).toList();
    _controller.add(List.unmodifiable(active));
  }

  Stream<List<CampusModel>> getCampuses() {
    Future.microtask(_emit);
    return _controller.stream;
  }

  Future<void> createCampus(CampusModel campus) async {
    final withId = CampusModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: campus.name,
      code: campus.code,
      universityId: campus.universityId,
      universityName: campus.universityName,
    );
    _campuses.add(withId);
    _emit();
  }

  Future<void> updateCampus(CampusModel campus) async {
    final index = _campuses.indexWhere((c) => c.id == campus.id);
    if (index != -1) {
      _campuses[index] = campus;
      _emit();
    }
  }

  Future<void> softDeleteCampus(String id) async {
    final index = _campuses.indexWhere((c) => c.id == id);
    if (index != -1) {
      _campuses[index] = _campuses[index].copyWith(isDeleted: true);
      _emit();
    }
  }
}
