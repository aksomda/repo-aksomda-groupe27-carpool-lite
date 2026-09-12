import 'package:flutter/material.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileProvider({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  });

  ProfileEntity? profile;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadProfile(String uid) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      profile = await getProfileUseCase(uid);
    } catch (e) {
      errorMessage = 'Impossible de charger le profil : $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(ProfileEntity updated) async {
    isLoading = true;
    notifyListeners();
    try {
      await updateProfileUseCase(updated);
      profile = updated;
      return true;
    } catch (e) {
      errorMessage = 'Impossible de mettre à jour le profil : $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}