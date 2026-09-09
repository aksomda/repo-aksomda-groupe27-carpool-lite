import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/academic_level.dart';

class AcademicLevelModel extends AcademicLevel {
  const AcademicLevelModel({
    required super.id,
    required super.name,
    required super.academicYear,
    required super.formationId,
    required super.formationName,
    super.isDeleted = false,
  });

  AcademicLevelModel copyWith({bool? isDeleted}) {
    return AcademicLevelModel(
      id: id,
      name: name,
      academicYear: academicYear,
      formationId: formationId,
      formationName: formationName,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory AcademicLevelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AcademicLevelModel(
      id: doc.id,
      name: data['name'] ?? '',
      academicYear: data['academicYear'] ?? '',
      formationId: data['formationId'] ?? '',
      formationName: data['formationName'] ?? '',
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'academicYear': academicYear,
      'formationId': formationId,
      'formationName': formationName,
      'isDeleted': isDeleted,
    };
  }
}
