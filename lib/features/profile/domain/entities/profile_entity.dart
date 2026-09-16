import '../../../auth/domain/entities/user_entity.dart';

/// Reprend les champs éditables de UserEntity. On réutilise l'enum Sex
/// de la feature auth plutôt que d'en recréer une copie.
class ProfileEntity {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final Sex sex;
  final String? universityId;
  final String? campusId;
  final bool isVerified;

  /// URL de la photo de profil (Firebase Storage), ou null si l'utilisateur
  /// n'en a pas encore importé une (avatar par initiales affiché à la place).
  final String? photoUrl;

  ProfileEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.sex,
    this.universityId,
    this.campusId,
    this.isVerified = false,
    this.photoUrl,
  });

  factory ProfileEntity.fromUser(UserEntity user) {
    return ProfileEntity(
      uid: user.uid,
      name: user.name,
      email: user.email,
      phone: user.phone,
      sex: user.sex,
      universityId: user.universityId,
      campusId: user.campusId,
      isVerified: user.isVerified,
    );
  }

  ProfileEntity copyWith({String? photoUrl}) {
    return ProfileEntity(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      sex: sex,
      universityId: universityId,
      campusId: campusId,
      isVerified: isVerified,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}