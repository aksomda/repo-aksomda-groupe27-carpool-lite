import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/ufr.dart';

class UfrModel extends Ufr {
  const UfrModel({
    required super.id,
    required super.name,
    required super.code,
    required super.universityId,
    required super.universityName,
    super.isDeleted = false,
  });

  UfrModel copyWith({
    String? name,
    String? code,
    String? universityId,
    String? universityName,
    bool? isDeleted,
  }) {
    return UfrModel(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      universityId: universityId ?? this.universityId,
      universityName: universityName ?? this.universityName,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory UfrModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UfrModel(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      universityId: data['universityId'] ?? '',
      universityName: data['universityName'] ?? '',
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'universityId': universityId,
      'universityName': universityName,
      'isDeleted': isDeleted,
    };
  }
}
