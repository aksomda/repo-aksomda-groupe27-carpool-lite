import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/university_entity.dart';
import '../../domain/usecases/get_universities_usecase.dart';
import '../../domain/usecases/add_university_usecase.dart';

class UniversityProvider extends ChangeNotifier {
  final GetUniversitiesUseCase getUniversitiesUseCase;
  final AddUniversityUseCase addUniversityUseCase;

  UniversityProvider({
    required this.getUniversitiesUseCase,
    required this.addUniversityUseCase,
  }) {
    _subscribe();
  }

  List<UniversityEntity> universities = [];
  bool isLoading = true;
  String? errorMessage;
  StreamSubscription<List<UniversityEntity>>? _subscription;

  void _subscribe() {
    _subscription = getUniversitiesUseCase().listen(
      (data) {
        universities = data;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        errorMessage = 'Impossible de charger les universités : $e';
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addUniversity(UniversityEntity university) async {
    try {
      await addUniversityUseCase(university);
    } catch (e) {
      errorMessage = 'Impossible d\'ajouter l\'université : $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}