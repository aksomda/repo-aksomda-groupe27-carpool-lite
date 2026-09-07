/// Convertit une coordonnée saisie en texte libre (ex: "11,20926° N",
/// "-4,41762° O", "12.3714") en [double] utilisable par Google Maps.
///
/// Retourne `null` si aucune valeur numérique n'a pu être extraite.
double? parseCoordinate(String? raw) {
  if (raw == null) return null;
  final input = raw.trim();
  if (input.isEmpty) return null;

  final numberMatch = RegExp(r'-?\d+(?:[.,]\d+)?').firstMatch(input);
  if (numberMatch == null) return null;

  final numberText = numberMatch.group(0)!.replaceAll(',', '.');
  double? value = double.tryParse(numberText);
  if (value == null) return null;

  final upper = input.toUpperCase();
  final isSouthOrWest = upper.contains('S') || upper.contains('O') || upper.contains('W');
  final isNorthOrEast = upper.contains('N') || upper.contains('E');

  // Les suffixes cardinaux (N/S/E/O/W) priment sur le signe déjà présent
  // dans le nombre : "-4,41762° O" comme "4,41762° O" doivent tous deux
  // donner une longitude négative.
  if (isSouthOrWest) {
    value = -value.abs();
  } else if (isNorthOrEast) {
    value = value.abs();
  }

  return value;
}
