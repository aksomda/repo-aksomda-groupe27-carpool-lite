/// Unité de Formation et de Recherche (UFR), rattachée à un campus.
class Ufr {
  final String id;
  final String name;
  final String code;
  final String campusId;
  final String campusName;

  /// Suppression logique : l'enregistrement n'est pas retiré de la base,
  /// il est simplement masqué des listes actives.
  final bool isDeleted;

  const Ufr({
    required this.id,
    required this.name,
    required this.code,
    required this.campusId,
    required this.campusName,
    this.isDeleted = false,
  });
}
