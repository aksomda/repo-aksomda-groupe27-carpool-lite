/// Niveau ou classe (ex: "Licence 1", "Master 2"), rattaché à une formation.
class AcademicLevel {
  final String id;
  final String name;
  final String academicYear;
  final String formationId;
  final String formationName;

  /// Suppression logique.
  final bool isDeleted;

  const AcademicLevel({
    required this.id,
    required this.name,
    required this.academicYear,
    required this.formationId,
    required this.formationName,
    this.isDeleted = false,
  });
}
