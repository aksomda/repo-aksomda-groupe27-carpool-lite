/// Validateurs réutilisables pour les champs de formulaire (`TextFormField`).
///
/// Chaque méthode retourne `null` si la valeur est valide, ou un message
/// d'erreur en français sinon, prêt à être branché sur le paramètre
/// `validator` d'un `TextFormField`.
class Validators {
  Validators._();

  static final RegExp _emailRegExp = RegExp(
    r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$',
  );

  // Numéros locaux (ex. 620 00 00 00) ou internationaux (+224 620 00 00 00).
  static final RegExp _phoneRegExp = RegExp(r'^\+?[0-9\s]{8,15}$');

  static final RegExp _plateRegExp = RegExp(
    r'^[A-Za-z0-9\-\s]{4,12}$',
  );

  /// Champ obligatoire générique.
  static String? required(String? value, {String field = 'Ce champ'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field est obligatoire.';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'adresse e-mail est obligatoire.';
    }
    if (!_emailRegExp.hasMatch(value.trim())) {
      return 'Adresse e-mail invalide.';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire.';
    }
    if (value.length < minLength) {
      return 'Le mot de passe doit contenir au moins $minLength caractères.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer le mot de passe.';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas.';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le numéro de téléphone est obligatoire.';
    }
    if (!_phoneRegExp.hasMatch(value.trim())) {
      return 'Numéro de téléphone invalide.';
    }
    return null;
  }

  /// Plaque d'immatriculation : accepte lettres, chiffres, espaces et tirets.
  static String? plateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La plaque d\'immatriculation est obligatoire.';
    }
    if (!_plateRegExp.hasMatch(value.trim())) {
      return 'Plaque d\'immatriculation invalide.';
    }
    return null;
  }

  /// Entier strictement positif (ex. nombre de places).
  static String? positiveInteger(String? value, {String field = 'La valeur'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field est obligatoire.';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return '$field doit être un nombre entier supérieur à zéro.';
    }
    return null;
  }

  /// Nombre décimal positif ou nul (ex. prix).
  static String? nonNegativeNumber(String? value, {String field = 'La valeur'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field est obligatoire.';
    }
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed < 0) {
      return '$field doit être un nombre positif.';
    }
    return null;
  }

  /// Longueur minimale générique (ex. nom, marque de véhicule).
  static String? minLength(
    String? value,
    int length, {
    String field = 'Ce champ',
  }) {
    if (value == null || value.trim().length < length) {
      return '$field doit contenir au moins $length caractères.';
    }
    return null;
  }

  /// Année de fabrication plausible pour un véhicule.
  static String? vehicleYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'année est obligatoire.';
    }
    final year = int.tryParse(value.trim());
    final currentYear = DateTime.now().year;
    if (year == null || year < 1970 || year > currentYear + 1) {
      return 'Année invalide.';
    }
    return null;
  }
}
