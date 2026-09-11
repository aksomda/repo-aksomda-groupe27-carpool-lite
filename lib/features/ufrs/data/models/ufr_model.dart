import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/ufr.dart';

class UfrModel extends Ufr {
  const UfrModel({
    required super.id,
    required super.name,
    required super.code,
    required super.campusId,
    required super.campusName,
    super.isDeleted = false,
  });

  UfrModel copyWith({
    String? name,
    String? code,
    String? campusId,
    String? campusName,
    bool? isDeleted,
  }) {
    return UfrModel(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      campusId: campusId ?? this.campusId,
      campusName: campusName ?? this.campusName,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory UfrModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UfrModel(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      campusId: data['campusId'] ?? '',
      campusName: data['campusName'] ?? '',
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'campusId': campusId,
      'campusName': campusName,
      'isDeleted': isDeleted,
    };
  }
}
