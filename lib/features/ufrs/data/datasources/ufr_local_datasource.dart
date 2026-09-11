import 'dart:async';

import '../models/ufr_model.dart';

/// Source de données locale (en mémoire) utilisée quand Firebase n'est pas
/// configuré. Gère l'ajout, la modification et la suppression logique.
class UfrLocalDataSource {
  UfrLocalDataSource._internal();

  static final UfrLocalDataSource instance = UfrLocalDataSource._internal();

  final List<UfrModel> _ufrs = [
    const UfrModel(
      id: 'ufr-demo-1',
      name: 'UFR Sciences Exactes et Appliquées',
      code: 'UFR-SEA',
      campusId: 'campus-demo-1',
      campusName: 'Campus de Zogona',
    ),
    const UfrModel(
      id: 'ufr-demo-2',
      name: 'UFR Sciences Économiques et de Gestion',
      code: 'UFR-SEG',
      campusId: 'campus-demo-1',
      campusName: 'Campus de Zogona',
    ),
  ];

  final StreamController<List<UfrModel>> _controller =
      StreamController<List<UfrModel>>.broadcast();

  void _emit() {
    final active = _ufrs.where((u) => !u.isDeleted).toList();
    _controller.add(List.unmodifiable(active));
  }

  Stream<List<UfrModel>> getUfrs() {
    Future.microtask(_emit);
    return _controller.stream;
  }

  Future<void> createUfr(UfrModel ufr) async {
    final withId = UfrModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: ufr.name,
      code: ufr.code,
      campusId: ufr.campusId,
      campusName: ufr.campusName,
    );
    _ufrs.add(withId);
    _emit();
  }

  Future<void> updateUfr(UfrModel ufr) async {
    final index = _ufrs.indexWhere((u) => u.id == ufr.id);
    if (index != -1) {
      _ufrs[index] = ufr;
      _emit();
    }
  }

  Future<void> softDeleteUfr(String id) async {
    final index = _ufrs.indexWhere((u) => u.id == id);
    if (index != -1) {
      _ufrs[index] = _ufrs[index].copyWith(isDeleted: true);
      _emit();
    }
  }
}
