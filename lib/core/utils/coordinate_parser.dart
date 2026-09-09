/// Convertit une coordonnée stockée sous forme de texte en double.
/// Accepte notamment : "12.3714", "12,3714", "12,3714° N" et "-1,5197° O".
double? parseCoordinate(String? value) {
  if (value == null || value.trim().isEmpty) return null;

  var normalized = value.trim().toUpperCase();
  var sign = 1.0;

  if (normalized.contains('S') || normalized.contains('O') || normalized.contains('W')) {
    sign = -1.0;
  }

  normalized = normalized
      .replaceAll(',', '.')
      .replaceAll(RegExp(r'[^0-9+\-.]'), ' ')
      .trim();

  final match = RegExp(r'[-+]?\d+(?:\.\d+)?').firstMatch(normalized);
  if (match == null) return null;

  final number = double.tryParse(match.group(0)!);
  if (number == null) return null;

  return number.abs() * sign;
}
