import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.phone,
    required super.sex,
    super.universityId,
    super.campusId,
    super.isVerified,
    super.isActive,
    super.role,
  });

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'Les données de l’utilisateur sont introuvables.',
      );
    }

    final String? sexValue = data['sex'] as String?;

    if (sexValue == null) {
      throw Exception(
        'Le sexe de l’utilisateur est introuvable.',
      );
    }

    final Sex sex = Sex.values.firstWhere(
      (value) => value.name == sexValue,
      orElse: () => throw Exception(
        'Valeur du sexe invalide : $sexValue',
      ),
    );

    return UserModel(
      uid: document.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      sex: sex,
      universityId: data['universityId'] as String?,
      campusId: data['campusId'] as String?,
      isVerified: data['isVerified'] as bool? ?? false,
      // Les comptes existants restent actifs après la migration.
      isActive: data['isActive'] as bool? ?? true,
      role: data['role'] as String? ?? 'student',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'sex': sex.name,
      'universityId': universityId,
      'campusId': campusId,
      'isVerified': isVerified,
      'isActive': isActive,
      'role': role,
    };
  }

  factory UserModel.fromEntity(UserEntity user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      name: user.name,
      phone: user.phone,
      sex: user.sex,
      universityId: user.universityId,
      campusId: user.campusId,
      isVerified: user.isVerified,
      isActive: user.isActive,
      role: user.role,
    );
  }
}
