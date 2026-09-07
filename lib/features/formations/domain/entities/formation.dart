/// Formation (filière/programme d'études), rattachée à une UFR.
class Formation {
  final String id;
  final String name;
  final String code;
  final String diploma;
  final String ufrId;
  final String ufrName;

  /// Suppression logique.
  final bool isDeleted;

  const Formation({
    required this.id,
    required this.name,
    required this.code,
    required this.diploma,
    required this.ufrId,
    required this.ufrName,
    this.isDeleted = false,
  });
}
