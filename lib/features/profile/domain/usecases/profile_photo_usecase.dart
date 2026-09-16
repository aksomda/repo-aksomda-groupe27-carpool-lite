import 'dart:typed_data';

import '../repositories/profile_repository.dart';

class UpdateProfilePhotoUseCase {
  final ProfileRepository repository;

  UpdateProfilePhotoUseCase(this.repository);

  Future<String> call(String uid, Uint8List bytes) => repository.updatePhoto(uid, bytes);
}