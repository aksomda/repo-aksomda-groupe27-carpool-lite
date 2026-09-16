/// Formatage des dates et heures pour l'affichage.
///
/// Le projet n'ayant pas de dépendance à `intl`, ces helpers reproduisent
/// les formats déjà utilisés dans les écrans (jj/MM/aaaa et HH:mm) afin
/// d'éviter que chaque écran redéfinisse ses propres méthodes privées.
class DateFormatter {
  DateFormatter._();

  static const List<String> _months = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  static const List<String> _weekDays = [
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
    'dimanche',
  ];

  static String _pad(int value) => value.toString().padLeft(2, '0');

  /// 05/03/2026
  static String formatDate(DateTime date) =>
      '${_pad(date.day)}/${_pad(date.month)}/${date.year}';

  /// 08:30
  static String formatTime(DateTime date) =>
      '${_pad(date.hour)}:${_pad(date.minute)}';

  /// 05/03/2026 à 08:30
  static String formatDateTime(DateTime date) =>
      '${formatDate(date)} à ${formatTime(date)}';

  /// jeudi 5 mars 2026
  static String formatLongDate(DateTime date) {
    final weekDay = _weekDays[date.weekday - 1];
    final month = _months[date.month - 1];
    return '$weekDay ${date.day} $month ${date.year}';
  }

  /// 5 mars
  static String formatDayAndMonth(DateTime date) =>
      '${date.day} ${_months[date.month - 1]}';

  /// Analyse une date au format ISO (yyyy-MM-dd) ou jj/MM/aaaa.
  /// Retourne `null` si la chaîne est vide ou illisible.
  static DateTime? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final raw = value.trim();

    final isoDate = DateTime.tryParse(raw);
    if (isoDate != null) return isoDate;

    final parts = raw.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);

      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  /// "il y a 5 minutes", "il y a 2 jours"... Utilisé pour les
  /// notifications et les messages.
  static String timeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inSeconds < 60) return 'à l\'instant';
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'il y a $minutes minute${minutes > 1 ? 's' : ''}';
    }
    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'il y a $hours heure${hours > 1 ? 's' : ''}';
    }
    if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'il y a $days jour${days > 1 ? 's' : ''}';
    }

    return formatDate(date);
  }

  /// Vrai si les deux dates tombent le même jour calendaire.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
