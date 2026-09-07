import 'dart:async';

import '../models/university_model.dart';

/// Source de données locale (en mémoire), utilisée comme solution de repli
/// lorsque Firebase/Firestore n'est pas configuré. Elle permet de tester
/// graphiquement l'écran de gestion des universités (liste + ajout) sans
/// dépendre d'un projet Firebase réel.
///
/// Les données ne sont pas persistées : elles sont réinitialisées à chaque
/// redémarrage de l'application.
class UniversityLocalDataSource {
  UniversityLocalDataSource._internal();

  static final UniversityLocalDataSource instance =
      UniversityLocalDataSource._internal();

  final List<UniversityModel> _universities = [
    UniversityModel(
      id: 'demo-1',
      name: 'Université Joseph Ki-Zerbo',
      city: 'Ouagadougou',
      latitude: '12,3714° N',
      longitude: '-1,5197° O',
      address: "Avenue de l'Indépendance",
    ),
    UniversityModel(
      id: 'demo-2',
      name: 'Université Nazi Boni',
      city: 'Bobo-Dioulasso',
      latitude: '11,1771° N',
      longitude: '-4,2979° O',
      address: 'Route de Dédougou',
    ),
  ];

  final StreamController<List<UniversityModel>> _controller =
      StreamController<List<UniversityModel>>.broadcast();

  Stream<List<UniversityModel>> getUniversities() {
    // On émet l'état courant à chaque nouvel abonnement (comportement
    // similaire à un StreamBuilder branché sur Firestore).
    Future.microtask(() => _controller.add(List.unmodifiable(_universities)));
    return _controller.stream;
  }

  Future<void> createUniversity(UniversityModel university) async {
    final withId = UniversityModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: university.name,
      city: university.city,
      latitude: university.latitude,
      longitude: university.longitude,
      address: university.address,
    );
    _universities.add(withId);
    _controller.add(List.unmodifiable(_universities));
  }
}
