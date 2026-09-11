import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/formation.dart';

class FormationModel extends Formation {
  const FormationModel({
    required super.id,
    required super.name,
    required super.code,
    required super.diploma,
    required super.ufrId,
    required super.ufrName,
    super.isDeleted = false,
  });

  FormationModel copyWith({bool? isDeleted}) {
    return FormationModel(
      id: id,
      name: name,
      code: code,
      diploma: diploma,
      ufrId: ufrId,
      ufrName: ufrName,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory FormationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FormationModel(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      diploma: data['diploma'] ?? '',
      ufrId: data['ufrId'] ?? '',
      ufrName: data['ufrName'] ?? '',
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'diploma': diploma,
      'ufrId': ufrId,
      'ufrName': ufrName,
      'isDeleted': isDeleted,
    };
  }
}
