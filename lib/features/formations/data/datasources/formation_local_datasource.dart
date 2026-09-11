import 'dart:async';

import '../models/formation_model.dart';

/// Source de données locale (en mémoire) utilisée quand Firebase n'est pas
/// configuré. Gère l'ajout, la modification et la suppression logique.
class FormationLocalDataSource {
  FormationLocalDataSource._internal();

  static final FormationLocalDataSource instance =
      FormationLocalDataSource._internal();

  final List<FormationModel> _formations = [
    const FormationModel(
      id: 'formation-demo-1',
      name: 'Licence en Informatique',
      code: 'LIC-INFO',
      diploma: 'Licence',
      ufrId: 'ufr-demo-1',
      ufrName: 'UFR Sciences Exactes et Appliquées',
    ),
    const FormationModel(
      id: 'formation-demo-2',
      name: 'Master en Réseaux et Télécoms',
      code: 'MAS-RT',
      diploma: 'Master',
      ufrId: 'ufr-demo-1',
      ufrName: 'UFR Sciences Exactes et Appliquées',
    ),
  ];

  final StreamController<List<FormationModel>> _controller =
      StreamController<List<FormationModel>>.broadcast();

  void _emit() {
    final active = _formations.where((f) => !f.isDeleted).toList();
    _controller.add(List.unmodifiable(active));
  }

  Stream<List<FormationModel>> getFormations() {
    Future.microtask(_emit);
    return _controller.stream;
  }

  Future<void> createFormation(FormationModel formation) async {
    final withId = FormationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: formation.name,
      code: formation.code,
      diploma: formation.diploma,
      ufrId: formation.ufrId,
      ufrName: formation.ufrName,
    );
    _formations.add(withId);
    _emit();
  }

  Future<void> updateFormation(FormationModel formation) async {
    final index = _formations.indexWhere((f) => f.id == formation.id);
    if (index != -1) {
      _formations[index] = formation;
      _emit();
    }
  }

  Future<void> softDeleteFormation(String id) async {
    final index = _formations.indexWhere((f) => f.id == id);
    if (index != -1) {
      _formations[index] = _formations[index].copyWith(isDeleted: true);
      _emit();
    }
  }
}
