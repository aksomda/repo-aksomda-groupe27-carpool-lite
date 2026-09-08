enum Sex {
  homme,
  femme,
}

class UserEntity {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final Sex sex;
  final String? universityId;
  final String? campusId;
  final bool isVerified;
  final String role;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.sex,
    this.universityId,
    this.campusId,
    this.isVerified = false,
    this.role = 'student',
  });
}