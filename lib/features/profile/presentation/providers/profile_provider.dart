import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/profile_photo_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdateProfilePhotoUseCase? updateProfilePhotoUseCase;

  ProfileProvider({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    this.updateProfilePhotoUseCase,
  });

  ProfileEntity? profile;

  bool isLoading = false;
  bool isUploadingPhoto = false;

  String? errorMessage;

  // ============================================================
  // CHARGER LE PROFIL
  // ============================================================

  Future<void> loadProfile(String uid) async {
    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      profile = await getProfileUseCase(uid);

      debugPrint(
        '✅ Profil chargé : ${profile?.name}',
      );

      debugPrint(
        '📸 Photo URL : ${profile?.photoUrl}',
      );
    } catch (e) {
      errorMessage = 'Impossible de charger le profil : $e';

      debugPrint(
        '❌ $errorMessage',
      );
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // MODIFIER LE PROFIL
  // ============================================================

  Future<bool> updateProfile(
    ProfileEntity updated,
  ) async {
    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      await updateProfileUseCase(updated);

      profile = updated;

      return true;
    } catch (e) {
      errorMessage =
          'Impossible de mettre à jour le profil : $e';

      return false;
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // MODIFIER LA PHOTO
  // ============================================================

  Future<bool> updatePhoto(
    String uid,
    Uint8List bytes,
  ) async {
    final useCase = updateProfilePhotoUseCase;

    if (useCase == null) {
      errorMessage =
          'Fonctionnalité photo non configurée dans l’Injector.';

      notifyListeners();

      return false;
    }

    isUploadingPhoto = true;
    errorMessage = null;

    notifyListeners();

    try {
      debugPrint('📸 ProfileProvider : début updatePhoto');

      final String url = await useCase(
        uid,
        bytes,
      );

      debugPrint(
        '🔗 ProfileProvider : URL reçue = $url',
      );

      // Mise à jour immédiate du profil affiché
      if (profile != null) {
        profile = profile!.copyWith(
          photoUrl: url,
        );
      }

      debugPrint(
        '✅ ProfileProvider : photo mise à jour',
      );

      return true;
    } catch (e) {
      errorMessage =
          "Impossible d'importer la photo : $e";

      debugPrint(
        '❌ $errorMessage',
      );

      return false;
    } finally {
      isUploadingPhoto = false;

      notifyListeners();
    }
  }
}