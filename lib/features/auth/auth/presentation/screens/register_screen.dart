import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../../domain/entities/user_entity.dart';
import 'verify_student_screen.dart';

class RegisterScreen extends StatefulWidget {
  final AuthProvider authProvider;

  const RegisterScreen({
    super.key,
    required this.authProvider,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _customUniversityController = TextEditingController();
  final _customCampusController = TextEditingController();

  // ============================================================
  // ÉTAPE
  // ============================================================

  int _currentStep = 0;

  // ============================================================
  // TÉLÉPHONE
  // ============================================================

  String _selectedPhoneCountry = 'Guinée';
  String _selectedPhoneCode = '+224';

  final List<Map<String, String>> _phoneCountries = [
    {'name': 'Guinée', 'code': '+224'},
    {'name': 'Sénégal', 'code': '+221'},
    {'name': 'Côte d’Ivoire', 'code': '+225'},
    {'name': 'Mali', 'code': '+223'},
    {'name': 'Burkina Faso', 'code': '+226'},
    {'name': 'Ghana', 'code': '+233'},
    {'name': 'Nigeria', 'code': '+234'},
    {'name': 'Gambie', 'code': '+220'},
    {'name': 'Sierra Leone', 'code': '+232'},
    {'name': 'Liberia', 'code': '+231'},
    {'name': 'Cameroun', 'code': '+237'},
    {'name': 'Congo', 'code': '+242'},
    {'name': 'RD Congo', 'code': '+243'},
    {'name': 'Gabon', 'code': '+241'},
    {'name': 'Togo', 'code': '+228'},
    {'name': 'Bénin', 'code': '+229'},
    {'name': 'Niger', 'code': '+227'},
    {'name': 'Maroc', 'code': '+212'},
    {'name': 'Algérie', 'code': '+213'},
    {'name': 'Tunisie', 'code': '+216'},
    {'name': 'Égypte', 'code': '+20'},
    {'name': 'Afrique du Sud', 'code': '+27'},
    {'name': 'Kenya', 'code': '+254'},
    {'name': 'Ouganda', 'code': '+256'},
    {'name': 'Tanzanie', 'code': '+255'},
    {'name': 'Éthiopie', 'code': '+251'},
    {'name': 'Rwanda', 'code': '+250'},
    {'name': 'Burundi', 'code': '+257'},
    {'name': 'Zambie', 'code': '+260'},
    {'name': 'Zimbabwe', 'code': '+263'},
    {'name': 'Mozambique', 'code': '+258'},
    {'name': 'France', 'code': '+33'},
    {'name': 'Belgique', 'code': '+32'},
    {'name': 'Canada', 'code': '+1'},
  ];

  // ============================================================
  // SEXE
  // ============================================================

  Sex? _selectedSex;

  // ============================================================
  // UNIVERSITÉS
  // ============================================================

  String _selectedUniversityCountry = 'Guinée';

  String? _selectedUniversity;
  String? _selectedCampus;

  bool _useCustomUniversity = false;
  bool _useCustomCampus = false;

  final List<String> _universityCountries = [
    'Guinée',
    'Sénégal',
    'Côte d’Ivoire',
    'Mali',
    'Burkina Faso',
    'Ghana',
    'Nigeria',
    'Gambie',
    'Sierra Leone',
    'Liberia',
    'Cameroun',
    'Congo',
    'RD Congo',
    'Gabon',
    'Togo',
    'Bénin',
    'Niger',
    'Maroc',
    'Algérie',
    'Tunisie',
    'Égypte',
    'Afrique du Sud',
    'Kenya',
    'Ouganda',
    'Tanzanie',
    'Éthiopie',
    'Rwanda',
    'Burundi',
    'Zambie',
    'Zimbabwe',
    'Mozambique',
  ];

  final Map<String, List<String>> _universitiesByCountry = {
    'Guinée': [
      'Université Nongo Conakry',
      'Université Gamal Abdel Nasser de Conakry',
      'Université Général Lansana Conté de Sonfonia',
      'Université Mahatma Gandhi',
      'Université Kofi Annan de Guinée',
    ],
    'Sénégal': [
      'Université Cheikh Anta Diop',
      'Université Gaston Berger',
      'Université Alioune Diop',
    ],
    'Côte d’Ivoire': [
      'Université Félix Houphouët-Boigny',
      'Université Nangui Abrogoua',
      'Université Alassane Ouattara',
    ],
    'Mali': [
      'Université des Sciences Techniques et de Technologies de Bamako',
      'Université des Lettres et des Sciences Humaines de Bamako',
    ],
    'Burkina Faso': [
      'Université Joseph Ki-Zerbo',
      'Université Thomas Sankara',
    ],
    'Ghana': [
      'University of Ghana',
      'Kwame Nkrumah University of Science and Technology',
    ],
    'Nigeria': [
      'University of Lagos',
      'University of Nigeria',
      'University of Ibadan',
    ],
    'Gambie': [
      'University of The Gambia',
    ],
    'Sierra Leone': [
      'University of Sierra Leone',
      'Njala University',
    ],
    'Liberia': [
      'University of Liberia',
    ],
    'Cameroun': [
      'Université de Yaoundé I',
      'Université de Yaoundé II',
      'Université de Douala',
    ],
    'Congo': [
      'Université Marien Ngouabi',
    ],
    'RD Congo': [
      'Université de Kinshasa',
      'Université de Lubumbashi',
    ],
    'Gabon': [
      'Université Omar Bongo',
    ],
    'Togo': [
      'Université de Lomé',
    ],
    'Bénin': [
      'Université d’Abomey-Calavi',
    ],
    'Niger': [
      'Université Abdou Moumouni',
    ],
    'Maroc': [
      'Université Mohammed V',
      'Université Hassan II',
      'Université Cadi Ayyad',
    ],
    'Algérie': [
      'Université d’Alger',
      'Université de Béjaïa',
      'Université de Constantine',
    ],
    'Tunisie': [
      'Université de Tunis',
      'Université de Sfax',
      'Université de Carthage',
    ],
    'Égypte': [
      'Cairo University',
      'Alexandria University',
    ],
    'Afrique du Sud': [
      'University of Cape Town',
      'University of Johannesburg',
      'University of Pretoria',
    ],
    'Kenya': [
      'University of Nairobi',
      'Kenyatta University',
    ],
    'Ouganda': [
      'Makerere University',
    ],
    'Tanzanie': [
      'University of Dar es Salaam',
    ],
    'Éthiopie': [
      'Addis Ababa University',
    ],
    'Rwanda': [
      'University of Rwanda',
    ],
    'Burundi': [
      'University of Burundi',
    ],
    'Zambie': [
      'University of Zambia',
    ],
    'Zimbabwe': [
      'University of Zimbabwe',
    ],
    'Mozambique': [
      'Eduardo Mondlane University',
    ],
  };

  // ============================================================
  // CAMPUS
  // ============================================================

  final List<String> _campuses = [
    'Campus principal',
    'Lambanyi',
    'Sonfonia',
    'Ratoma',
  ];

  // ============================================================
  // ÉTAT
  // ============================================================

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // ============================================================
  // INIT / DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _customUniversityController.dispose();
    _customCampusController.dispose();
    super.dispose();
  }

  // ============================================================
  // FORMATAGE NOM
  // ============================================================

 String _formatName(String value) {
  final cleaned = value
      .replaceAll(RegExp(r"[^a-zA-ZÀ-ÿ' -]"), '')
      .replaceAll(RegExp(r'\s+'), ' ');

  if (cleaned.isEmpty) {
    return '';
  }

  return cleaned.split(' ').map((word) {
    if (word.isEmpty) {
      return word;
    }

    // Gère les noms comme :
    // O'NEIL -> O'Neil
    // JEAN-PIERRE -> Jean-Pierre
    final parts = word.split(RegExp(r"(['\-])"));

    return parts.map((part) {
      if (part == "'" || part == '-') {
        return part;
      }

      if (part.isEmpty) {
        return part;
      }

      return part[0].toUpperCase() +
          part.substring(1).toLowerCase();
    }).join();
  }).join(' ');
}

  // ============================================================
  // VALIDATION ÉTAPE 1
  // ============================================================

  bool _validateStep1() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      _showError('Veuillez entrer votre nom complet.');
      return false;
    }

    if (name.length < 2) {
      _showError('Le nom doit contenir au moins 2 caractères.');
      return false;
    }

    if (phone.isEmpty) {
      _showError('Veuillez entrer votre numéro de téléphone.');
      return false;
    }

    if (phone.length < 6) {
      _showError('Veuillez entrer un numéro de téléphone valide.');
      return false;
    }

    if (_selectedSex == null) {
      _showError('Veuillez sélectionner votre sexe.');
      return false;
    }

    return true;
  }

  // ============================================================
  // VALIDATION ÉTAPE 2
  // ============================================================

  bool _validateStep2() {
    if (_useCustomUniversity) {
      if (_customUniversityController.text.trim().isEmpty) {
        _showError('Veuillez entrer le nom de votre université.');
        return false;
      }
    } else {
      if (_selectedUniversity == null) {
        _showError('Veuillez sélectionner votre université.');
        return false;
      }
    }

    if (_useCustomCampus) {
      if (_customCampusController.text.trim().isEmpty) {
        _showError('Veuillez entrer le nom de votre campus.');
        return false;
      }
    } else {
      if (_selectedCampus == null) {
        _showError('Veuillez sélectionner votre campus.');
        return false;
      }
    }

    return true;
  }

  // ============================================================
  // VALIDATION EMAIL
  // ============================================================

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  // ============================================================
  // VALIDATION ÉTAPE 3
  // ============================================================

  bool _validateStep3() {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty) {
      _showError('Veuillez entrer votre adresse email.');
      return false;
    }

    if (!_isValidEmail(email)) {
      _showError('Veuillez entrer une adresse email valide.');
      return false;
    }

    if (password.isEmpty) {
      _showError('Veuillez entrer un mot de passe.');
      return false;
    }

    if (password.length < 6) {
      _showError(
        'Le mot de passe doit contenir au moins 6 caractères.',
      );
      return false;
    }

    if (confirmPassword.isEmpty) {
      _showError('Veuillez confirmer votre mot de passe.');
      return false;
    }

    if (password != confirmPassword) {
      _showError('Les mots de passe ne correspondent pas.');
      return false;
    }

    return true;
  }

  // ============================================================
  // MESSAGE ERREUR
  // ============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // ÉTAPE SUIVANTE
  // ============================================================

  void _nextStep() {
    FocusScope.of(context).unfocus();

    bool valid = false;

    if (_currentStep == 0) {
      valid = _validateStep1();
    } else if (_currentStep == 1) {
      valid = _validateStep2();
    }

    if (!valid) {
      return;
    }

    setState(() {
      _currentStep++;
    });
  }

  // ============================================================
  // ÉTAPE PRÉCÉDENTE
  // ============================================================

  void _previousStep() {
    FocusScope.of(context).unfocus();

    if (_currentStep == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _currentStep--;
    });
  }

  // ============================================================
  // INSCRIPTION
  // ============================================================

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_validateStep3()) {
      return;
    }

    if (_selectedSex == null) {
      _showError('Veuillez sélectionner votre sexe.');
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim().toLowerCase();

    final fullPhone = '$_selectedPhoneCode$phone';

    final university = _useCustomUniversity
        ? _customUniversityController.text.trim()
        : _selectedUniversity!;

    final campus = _useCustomCampus
        ? _customCampusController.text.trim()
        : _selectedCampus!;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await widget.authProvider.signUp(
        name: name,
        phone: fullPhone,
        sex: _selectedSex!,
        email: email,
        password: _passwordController.text,
        universityId: university,
        campusId: campus,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Inscription réussie ! Vérifiez votre compte.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyStudentScreen(
              authProvider: widget.authProvider,
            ),
          ),
        );
      } else {
        _showError(
          widget.authProvider.errorMessage ??
              'Une erreur est survenue pendant l’inscription.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showError(
        'Une erreur est survenue. Veuillez réessayer.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 30,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 520,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ==================================================
                    // LOGO
                    // ==================================================

 Center(
  child: Container(
    width: 105,
    height: 105,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Image.asset(
      'assets/images/logo_carpoollite.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.directions_car_rounded,
          color: theme.colorScheme.primary,
          size: 50,
        );
      },
    ),
  ),
),

                    const SizedBox(height: 22),

                    // ==================================================
                    // NOM APPLICATION
                    // ==================================================

                    const Text(
                      'CarPool Lite',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Covoiturage simple entre étudiants',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // INDICATEUR DES ÉTAPES
                    // ==================================================

                    _buildStepIndicator(theme),

                    const SizedBox(height: 20),

                    // ==================================================
                    // CARD
                    // ==================================================

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 25,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ==================================================
                          // TITRE
                          // ==================================================

                          Text(
                            _getStepTitle(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            _getStepSubtitle(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // ==================================================
                          // CONTENU ÉTAPE
                          // ==================================================

                          AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 250,
                            ),
                            child: _buildCurrentStep(theme),
                          ),

                          const SizedBox(height: 25),

                          // ==================================================
                          // BOUTONS
                          // ==================================================

                          Row(
                            children: [
                              if (_currentStep > 0)
                                Expanded(
                                  child: SizedBox(
                                    height: 54,
                                    child: OutlinedButton(
                                      onPressed:
                                          _isLoading
                                              ? null
                                              : _previousStep,
                                      style:
                                          OutlinedButton.styleFrom(
                                        foregroundColor:
                                            theme.colorScheme.primary,
                                        side: BorderSide(
                                          color: theme
                                              .colorScheme
                                              .primary,
                                        ),
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Retour',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              if (_currentStep > 0)
                                const SizedBox(width: 12),

                              Expanded(
                                child: SizedBox(
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : (_currentStep == 2
                                            ? _register
                                            : _nextStep),
                                    style:
                                        ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor:
                                          Colors.white,
                                      disabledBackgroundColor:
                                          Colors.grey.shade300,
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                          14,
                                        ),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                            children: [
                                              Text(
                                                _currentStep == 2
                                                    ? 'S’inscrire'
                                                    : 'Continuer',
                                                style:
                                                    const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Icon(
                                                _currentStep == 2
                                                    ? Icons
                                                        .check_rounded
                                                    : Icons
                                                        .arrow_forward_rounded,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // RETOUR CONNEXION
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          'Vous avez déjà un compte ?',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          child: Text(
                            'Se connecter',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // ==================================================
                    // SÉCURITÉ
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 15,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Vos données sont protégées',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INDICATEUR ÉTAPES
  // ============================================================

  Widget _buildStepIndicator(ThemeData theme) {
    const labels = [
      'Personnel',
      'Université',
      'Compte',
    ];

    return Row(
      children: List.generate(
        labels.length,
        (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive || isCompleted
                              ? theme.colorScheme.primary
                              : Colors.grey.shade200,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive
                              ? theme.colorScheme.primary
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(
                        bottom: 22,
                      ),
                      color: index < _currentStep
                          ? theme.colorScheme.primary
                          : Colors.grey.shade200,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // TITRE ÉTAPE
  // ============================================================

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Informations personnelles';
      case 1:
        return 'Votre université';
      case 2:
        return 'Créer votre compte';
      default:
        return 'Inscription';
    }
  }

  // ============================================================
  // SOUS-TITRE ÉTAPE
  // ============================================================

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'Parlez-nous un peu de vous.';
      case 1:
        return 'Indiquez votre établissement et votre campus.';
      case 2:
        return 'Choisissez vos identifiants de connexion.';
      default:
        return '';
    }
  }

  // ============================================================
  // ÉTAPE COURANTE
  // ============================================================

  Widget _buildCurrentStep(ThemeData theme) {
    switch (_currentStep) {
      case 0:
        return _buildPersonalStep(theme);

      case 1:
        return _buildUniversityStep(theme);

      case 2:
        return _buildAccountStep();

      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================
  // ÉTAPE 1 : INFORMATIONS PERSONNELLES
  // ============================================================

  Widget _buildPersonalStep(ThemeData theme) {
    return Column(
      key: const ValueKey('personal'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          controller: _nameController,
          label: 'Nom complet',
          hint: 'Exemple : Mayeny Cherif',
          prefixIcon: Icons.person_outline,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          maxLength: 60,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r"[a-zA-ZÀ-ÿ' -]"),
            ),
          ],
          onChanged: (value) {
            final formatted = _formatName(value);

            if (formatted != value) {
              _nameController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(
                  offset: formatted.length,
                ),
              );
            }
          },
        ),

        const SizedBox(height: 18),

        // ==========================================================
        // PAYS + INDICATIF
        // ==========================================================

        DropdownButtonFormField<String>(
          initialValue: _selectedPhoneCountry,
          decoration: _inputDecoration(
            theme,
            label: 'Pays',
            hint: 'Sélectionnez votre pays',
            icon: Icons.public_outlined,
          ),
          items: _phoneCountries.map((country) {
            return DropdownMenuItem<String>(
              value: country['name'],
              child: Text(
                '${country['name']} (${country['code']})',
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            final selected = _phoneCountries.firstWhere(
              (country) => country['name'] == value,
            );

            setState(() {
              _selectedPhoneCountry = value;
              _selectedPhoneCode = selected['code']!;
            });
          },
        ),

        const SizedBox(height: 18),

        AuthTextField(
          controller: _phoneController,
          label: 'Numéro de téléphone',
          hint: 'Exemple : 621234567',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          maxLength: 15,
        ),

        const SizedBox(height: 18),

        // ==========================================================
        // SEXE
        // ==========================================================

        DropdownButtonFormField<Sex>(
          initialValue: _selectedSex,
          decoration: _inputDecoration(
            theme,
            label: 'Sexe',
            hint: 'Sélectionnez votre sexe',
            icon: Icons.person_outline,
          ),
          items: const [
            DropdownMenuItem<Sex>(
              value: Sex.homme,
              child: Text('Homme'),
            ),
            DropdownMenuItem<Sex>(
              value: Sex.femme,
              child: Text('Femme'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedSex = value;
            });
          },
        ),
      ],
    );
  }

  // ============================================================
  // ÉTAPE 2 : UNIVERSITÉ
  // ============================================================

  Widget _buildUniversityStep(ThemeData theme) {
    final universities =
        _universitiesByCountry[_selectedUniversityCountry] ??
            [];

    return Column(
      key: const ValueKey('university'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ==========================================================
        // UNIVERSITÉ PERSONNALISÉE
        // ==========================================================

        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _useCustomUniversity,
          activeColor: theme.colorScheme.primary,
          title: const Text(
            'Mon université n’est pas dans la liste',
          ),
          onChanged: (value) {
            setState(() {
              _useCustomUniversity = value ?? false;

              if (_useCustomUniversity) {
                _selectedUniversity = null;
              } else {
                _customUniversityController.clear();
              }
            });
          },
        ),

        const SizedBox(height: 8),

        if (!_useCustomUniversity) ...[
          DropdownButtonFormField<String>(
            initialValue: _selectedUniversityCountry,
            decoration: _inputDecoration(
              theme,
              label: 'Pays de l’université',
              hint: 'Sélectionnez le pays',
              icon: Icons.public_outlined,
            ),
            items: _universityCountries.map((country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(country),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedUniversityCountry = value;
                _selectedUniversity = null;
              });
            },
          ),

          const SizedBox(height: 18),

          DropdownButtonFormField<String>(
            initialValue: _selectedUniversity,
            decoration: _inputDecoration(
              theme,
              label: 'Université',
              hint: 'Sélectionnez votre université',
              icon: Icons.school_outlined,
            ),
            items: universities.map((university) {
              return DropdownMenuItem<String>(
                value: university,
                child: Text(
                  university,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedUniversity = value;
              });
            },
          ),
        ] else ...[
          AuthTextField(
            controller: _customUniversityController,
            label: 'Nom de l’université',
            hint: 'Entrez le nom de votre université',
            prefixIcon: Icons.school_outlined,
          ),
        ],

        const SizedBox(height: 20),

        // ==========================================================
        // CAMPUS PERSONNALISÉ
        // ==========================================================

        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _useCustomCampus,
          activeColor: theme.colorScheme.primary,
          title: const Text(
            'Mon campus n’est pas dans la liste',
          ),
          onChanged: (value) {
            setState(() {
              _useCustomCampus = value ?? false;

              if (_useCustomCampus) {
                _selectedCampus = null;
              } else {
                _customCampusController.clear();
              }
            });
          },
        ),

        const SizedBox(height: 8),

        if (!_useCustomCampus)
          DropdownButtonFormField<String>(
            initialValue: _selectedCampus,
            decoration: _inputDecoration(
              theme,
              label: 'Campus',
              hint: 'Sélectionnez votre campus',
              icon: Icons.location_on_outlined,
            ),
            items: _campuses.map((campus) {
              return DropdownMenuItem<String>(
                value: campus,
                child: Text(campus),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCampus = value;
              });
            },
          )
        else
          AuthTextField(
            controller: _customCampusController,
            label: 'Nom du campus',
            hint: 'Entrez le nom de votre campus',
            prefixIcon: Icons.location_on_outlined,
          ),
      ],
    );
  }

  // ============================================================
  // ÉTAPE 3 : COMPTE
  // ============================================================

  Widget _buildAccountStep() {
    return Column(
      key: const ValueKey('account'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          controller: _emailController,
          label: 'Adresse email',
          hint: 'exemple@email.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            final lower = value.toLowerCase();

            if (lower != value) {
              _emailController.value = TextEditingValue(
                text: lower,
                selection: TextSelection.collapsed(
                  offset: lower.length,
                ),
              );
            }
          },
        ),

        const SizedBox(height: 18),

        AuthTextField(
          controller: _passwordController,
          label: 'Mot de passe',
          hint: 'Minimum 6 caractères',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            tooltip: _obscurePassword
                ? 'Afficher le mot de passe'
                : 'Masquer le mot de passe',
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),

        const SizedBox(height: 18),

        AuthTextField(
          controller: _confirmPasswordController,
          label: 'Confirmer le mot de passe',
          hint: 'Retapez votre mot de passe',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            tooltip: _obscureConfirmPassword
                ? 'Afficher le mot de passe'
                : 'Masquer le mot de passe',
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword =
                    !_obscureConfirmPassword;
              });
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STYLE INPUT
  // ============================================================

  InputDecoration _inputDecoration(
    ThemeData theme, {
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      labelStyle: TextStyle(
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
    );
  }
}