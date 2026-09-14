// TODO: ProfileModel : mapping Firestore <-> ProfileEntity.
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.phone,
    required super.sex,
    super.universityId,
    super.campusId,
    super.isVerified,
  });

  factory ProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Profil introuvable.');
    }

    final String? sexValue = data['sex'] as String?;
    final Sex sex = Sex.values.firstWhere(
      (v) => v.name == sexValue,
      orElse: () => throw Exception('Valeur du sexe invalide : $sexValue'),
    );

    return ProfileModel(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      sex: sex,
      universityId: data['universityId'] as String?,
      campusId: data['campusId'] as String?,
      isVerified: data['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestoreUpdate() {
    return {
      'name': name,
      'phone': phone,
      'sex': sex.name,
      'universityId': universityId,
      'campusId': campusId,
    };
  }
}