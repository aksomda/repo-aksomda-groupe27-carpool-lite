/// Campus physique (ex: "Campus de Nasso"), rattaché à une université.
/// Une université peut avoir plusieurs campus ; chaque UFR est ensuite
/// rattachée à un campus (voir lib/features/ufrs).
class Campus {
  final String id;
  final String name;
  final String code;
  final String universityId;
  final String universityName;

  /// Suppression logique : l'enregistrement n'est pas retiré de la base,
  /// il est simplement masqué des listes actives.
  final bool isDeleted;

  const Campus({
    required this.id,
    required this.name,
    required this.code,
    required this.universityId,
    required this.universityName,
    this.isDeleted = false,
  });
}
