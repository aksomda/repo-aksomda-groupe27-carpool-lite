import 'dart:async';

import '../models/academic_level_model.dart';

/// Source de données locale (en mémoire) utilisée quand Firebase n'est pas
/// configuré. Gère l'ajout, la modification et la suppression logique.
class AcademicLevelLocalDataSource {
  AcademicLevelLocalDataSource._internal();

  static final AcademicLevelLocalDataSource instance =
      AcademicLevelLocalDataSource._internal();

  final List<AcademicLevelModel> _levels = [
    const AcademicLevelModel(
      id: 'level-demo-1',
      name: 'Licence 1',
      academicYear: '2025-2026',
      formationId: 'formation-demo-1',
      formationName: 'Licence en Informatique',
    ),
    const AcademicLevelModel(
      id: 'level-demo-2',
      name: 'Licence 2',
      academicYear: '2025-2026',
      formationId: 'formation-demo-1',
      formationName: 'Licence en Informatique',
    ),
  ];

  final StreamController<List<AcademicLevelModel>> _controller =
      StreamController<List<AcademicLevelModel>>.broadcast();

  void _emit() {
    final active = _levels.where((l) => !l.isDeleted).toList();
    _controller.add(List.unmodifiable(active));
  }

  Stream<List<AcademicLevelModel>> getLevels() {
    Future.microtask(_emit);
    return _controller.stream;
  }

  Future<void> createLevel(AcademicLevelModel level) async {
    final withId = AcademicLevelModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: level.name,
      academicYear: level.academicYear,
      formationId: level.formationId,
      formationName: level.formationName,
    );
    _levels.add(withId);
    _emit();
  }

  Future<void> updateLevel(AcademicLevelModel level) async {
    final index = _levels.indexWhere((l) => l.id == level.id);
    if (index != -1) {
      _levels[index] = level;
      _emit();
    }
  }

  Future<void> softDeleteLevel(String id) async {
    final index = _levels.indexWhere((l) => l.id == id);
    if (index != -1) {
      _levels[index] = _levels[index].copyWith(isDeleted: true);
      _emit();
    }
  }
}
