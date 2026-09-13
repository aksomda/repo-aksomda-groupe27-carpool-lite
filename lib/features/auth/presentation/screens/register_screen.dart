import 'package:flutter/material.dart';

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
  // ÉTAPE ACTUELLE
  // ============================================================

  int _currentStep = 0;

  // ============================================================
  // INFORMATIONS PERSONNELLES
  // ============================================================

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  Sex? _selectedSex;

  // ============================================================
  // INFORMATIONS UNIVERSITAIRES
  // ============================================================

  String? _selectedUniversity;
  String? _selectedCampus;

  // ============================================================
  // INFORMATIONS DU COMPTE
  // ============================================================

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ============================================================
  // ÉTAT DES MOTS DE PASSE
  // ============================================================

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // ============================================================
  // LISTE DES UNIVERSITÉS
  // ============================================================

  final List<String> _universities = [
    'Université Nongo Conakry',
    'Université Gamal Abdel Nasser de Conakry',
    'Université Général Lansana Conté de Sonfonia',
    'Université Mahatma Gandhi',
    'Université Kofi Annan de Guinée',
  ];

  // ============================================================
  // LISTE DES CAMPUS
  // ============================================================

  final List<String> _campuses = [
    'Campus principal',
    'Campus de Lambanyi',
    'Campus de Sonfonia',
    'Campus de Ratoma',
  ];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // VALIDATION ÉTAPE 1
  // ============================================================

  bool _validateStep1() {
    // Valider les champs du formulaire
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    // Vérifier le sexe
    if (_selectedSex == null) {
      _showMessage('Veuillez sélectionner votre sexe.');
      return false;
    }

    return true;
  }

  // ============================================================
  // VALIDATION ÉTAPE 2
  // ============================================================

  bool _validateStep2() {
    if (_selectedUniversity == null) {
      _showMessage('Veuillez sélectionner votre université.');
      return false;
    }

    if (_selectedCampus == null) {
      _showMessage('Veuillez sélectionner votre campus.');
      return false;
    }

    return true;
  }

  // ============================================================
  // VALIDATION ÉTAPE 3
  // ============================================================

  bool _validateStep3() {
    // Vérification des champs email/mot de passe
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    return true;
  }

  // ============================================================
  // ÉTAPE SUIVANTE
  // ============================================================

  void _nextStep() {
    FocusScope.of(context).unfocus();

    bool isValid = false;

    switch (_currentStep) {
      case 0:
        isValid = _validateStep1();
        break;

      case 1:
        isValid = _validateStep2();
        break;

      default:
        return;
    }

    if (!isValid) {
      return;
    }

    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
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

    // Vérification de l'étape 3
    if (!_validateStep3()) {
      return;
    }

    // Vérifications supplémentaires
    if (_selectedSex == null) {
      _showMessage('Veuillez sélectionner votre sexe.');
      setState(() {
        _currentStep = 0;
      });
      return;
    }

    if (_selectedUniversity == null) {
      _showMessage('Veuillez sélectionner votre université.');
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    if (_selectedCampus == null) {
      _showMessage('Veuillez sélectionner votre campus.');
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    // ==========================================================
    // RÉCUPÉRATION DES DONNÉES
    // ==========================================================

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final universityId = _selectedUniversity!;
    final campusId = _selectedCampus!;
    final sex = _selectedSex!;

    // ==========================================================
    // APPEL AUTH PROVIDER
    // ==========================================================

    final bool success = await widget.authProvider.signUp(
      name: name,
      phone: phone,
      sex: sex,
      email: email,
      password: password,
      universityId: universityId,
      campusId: campusId,
    );

    if (!mounted) return;

    // ==========================================================
    // SUCCÈS
    // ==========================================================

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compte créé avec succès !',
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
    }

    // ==========================================================
    // ERREUR
    // ==========================================================

    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.authProvider.errorMessage ??
                'Une erreur est survenue lors de l’inscription.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // VALIDATION NOM
  // ============================================================

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Veuillez entrer votre nom.';
    }

    if (name.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères.';
    }

    return null;
  }

  // ============================================================
  // VALIDATION TÉLÉPHONE
  // ============================================================

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'Veuillez entrer votre numéro.';
    }

    // On garde uniquement les chiffres
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 8) {
      return 'Veuillez entrer un numéro valide.';
    }

    return null;
  }

  // ============================================================
  // VALIDATION EMAIL
  // ============================================================

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Veuillez entrer votre email.';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Veuillez entrer une adresse email valide.';
    }

    return null;
  }

  // ============================================================
  // VALIDATION MOT DE PASSE
  // ============================================================

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Veuillez entrer un mot de passe.';
    }

    if (password.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }

    return null;
  }

  // ============================================================
  // VALIDATION CONFIRMATION
  // ============================================================

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Veuillez confirmer votre mot de passe.';
    }

    if (confirmPassword != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas.';
    }

    return null;
  }

  // ============================================================
  // TITRE DE SECTION
  // ============================================================

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DROPDOWN SEXE
  // ============================================================

  Widget _buildSexDropdown() {
    return DropdownButtonFormField<Sex>(
      initialValue: _selectedSex,
      decoration: InputDecoration(
        labelText: 'Sexe',
        hintText: 'Sélectionnez votre sexe',
        prefixIcon: const Icon(
          Icons.wc_outlined,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: Sex.values.map((sex) {
        return DropdownMenuItem<Sex>(
          value: sex,
          child: Text(
            sex == Sex.homme ? 'Homme' : 'Femme',
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSex = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner votre sexe.';
        }

        return null;
      },
    );
  }

  // ============================================================
  // DROPDOWN UNIVERSITÉ
  // ============================================================

  Widget _buildUniversityDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedUniversity,
      decoration: InputDecoration(
        labelText: 'Université',
        hintText: 'Sélectionnez votre université',
        prefixIcon: const Icon(
          Icons.account_balance_outlined,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: _universities.map((university) {
        return DropdownMenuItem<String>(
          value: university,
          child: SizedBox(
            width: 280,
            child: Text(
              university,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedUniversity = value;

          // Le campus est réinitialisé lorsqu'une
          // autre université est sélectionnée.
          _selectedCampus = null;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner votre université.';
        }

        return null;
      },
    );
  }

  // ============================================================
  // DROPDOWN CAMPUS
  // ============================================================

  Widget _buildCampusDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCampus,
      decoration: InputDecoration(
        labelText: 'Campus',
        hintText: 'Sélectionnez votre campus',
        prefixIcon: const Icon(
          Icons.location_city_outlined,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: _campuses.map((campus) {
        return DropdownMenuItem<String>(
          value: campus,
          child: Text(
            campus,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _selectedUniversity == null
          ? null
          : (value) {
              setState(() {
                _selectedCampus = value;
              });
            },
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner votre campus.';
        }

        return null;
      },
    );
  }

  // ============================================================
  // CONTENU ÉTAPE 1
  // ============================================================

  Widget _buildPersonalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Informations personnelles',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Commençons par faire connaissance.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 25),

        // NOM
        AuthTextField(
          controller: _nameController,
          label: 'Nom complet',
          hint: 'Ex : Mayeny Chérif',
          prefixIcon: Icons.person_outline_rounded,
          keyboardType: TextInputType.name,
          validator: _validateName,
        ),

        const SizedBox(height: 17),

        // TÉLÉPHONE
        AuthTextField(
          controller: _phoneController,
          label: 'Numéro de téléphone',
          hint: 'Ex : 621 00 00 00',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: _validatePhone,
        ),

        const SizedBox(height: 17),

        // SEXE
        _buildSexDropdown(),

        const SizedBox(height: 27),

        // BOUTON
        _buildNextButton(
          label: 'Continuer',
          onPressed: _nextStep,
        ),
      ],
    );
  }

  // ============================================================
  // CONTENU ÉTAPE 2
  // ============================================================

  Widget _buildUniversityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(
          icon: Icons.school_outlined,
          title: 'Informations universitaires',
        ),

        const SizedBox(height: 7),

        Text(
          'Indiquez votre université et votre campus.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 25),

        // UNIVERSITÉ
        _buildUniversityDropdown(),

        const SizedBox(height: 17),

        // CAMPUS
        _buildCampusDropdown(),

        const SizedBox(height: 27),

        Row(
          children: [
            Expanded(
              child: _buildBackButton(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNextButton(
                label: 'Continuer',
                onPressed: _nextStep,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // CONTENU ÉTAPE 3
  // ============================================================

  Widget _buildAccountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Sécurité du compte',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Créez vos identifiants de connexion.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 25),

        // EMAIL
        AuthTextField(
          controller: _emailController,
          label: 'Adresse email',
          hint: 'Ex : etudiant@email.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),

        const SizedBox(height: 17),

        // MOT DE PASSE
        AuthTextField(
          controller: _passwordController,
          label: 'Mot de passe',
          hint: 'Minimum 6 caractères',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            tooltip: _obscurePassword
                ? 'Afficher'
                : 'Masquer',
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
          validator: _validatePassword,
        ),

        const SizedBox(height: 17),

        // CONFIRMATION MOT DE PASSE
        AuthTextField(
          controller: _confirmPasswordController,
          label: 'Confirmer le mot de passe',
          hint: 'Retapez votre mot de passe',
          prefixIcon: Icons.lock_reset_outlined,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            tooltip: _obscureConfirmPassword
                ? 'Afficher'
                : 'Masquer',
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
          validator: _validateConfirmPassword,
        ),

        const SizedBox(height: 27),

        // BOUTONS
        Row(
          children: [
            Expanded(
              child: _buildBackButton(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedBuilder(
                animation: widget.authProvider,
                builder: (context, child) {
                  final isLoading =
                      widget.authProvider.isLoading;

                  return SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                          isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                            Theme.of(context)
                                .colorScheme
                                .primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            Colors.grey.shade300,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Créer',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 7),
                                Icon(
                                  Icons.check_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // BOUTON CONTINUER
  // ============================================================

  Widget _buildNextButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOUTON RETOUR
  // ============================================================

  Widget _buildBackButton() {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: _previousStep,
        style: OutlinedButton.styleFrom(
          foregroundColor:
              Theme.of(context).colorScheme.primary,
          side: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              size: 19,
            ),
            SizedBox(width: 7),
            Text(
              'Retour',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INDICATEUR DES 3 ÉTAPES
  // ============================================================

  Widget _buildStepsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStep(
          number: '1',
          label: 'Personnel',
          active: _currentStep >= 0,
        ),

        _buildLine(
          active: _currentStep >= 1,
        ),

        _buildStep(
          number: '2',
          label: 'Université',
          active: _currentStep >= 1,
        ),

        _buildLine(
          active: _currentStep >= 2,
        ),

        _buildStep(
          number: '3',
          label: 'Compte',
          active: _currentStep >= 2,
        ),
      ],
    );
  }

  // ============================================================
  // ÉTAPE INDICATEUR
  // ============================================================

  Widget _buildStep({
    required String number,
    required String label,
    required bool active,
  }) {
    final primary =
        Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        AnimatedContainer(
          duration:
              const Duration(milliseconds: 250),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: active
                ? primary
                : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active
                ? primary
                : Colors.grey.shade600,
            fontWeight: active
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LIGNE ENTRE LES ÉTAPES
  // ============================================================

  Widget _buildLine({
    required bool active,
  }) {
    final primary =
        Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 250),
      width: 35,
      height: 2,
      margin: const EdgeInsets.only(
        left: 6,
        right: 6,
        bottom: 22,
      ),
      color: active
          ? primary
          : Colors.grey.shade300,
    );
  }

  // ============================================================
  // TITRE DYNAMIQUE
  // ============================================================

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'Étape 1 sur 3';

      case 1:
        return 'Étape 2 sur 3';

      case 2:
        return 'Étape 3 sur 3';

      default:
        return '';
    }
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: _previousStep,
        ),

        title: const Text(
          'Créer un compte',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            10,
            24,
            30,
          ),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,

                  children: [
                    // ==================================================
                    // LOGO
                    // ==================================================

                    Center(
                      child: AnimatedContainer(
                        duration:
                            const Duration(
                          milliseconds: 250,
                        ),

                        width: 75,
                        height: 75,

                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary,
                          borderRadius:
                              BorderRadius.circular(23),

                          boxShadow: [
                            BoxShadow(
                              color: theme
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset:
                                  const Offset(0, 9),
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons
                              .directions_car_filled_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // TITRE
                    // ==================================================

                    const Text(
                      'Rejoignez CarPool Lite 🚗',
                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        fontSize: 25,
                        fontWeight:
                            FontWeight.bold,
                        letterSpacing: -0.4,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Créez votre compte étudiant',
                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        fontSize: 15,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // INDICATEUR
                    // ==================================================

                    _buildStepsIndicator(),

                    const SizedBox(height: 8),

                    Text(
                      _getStepSubtitle(),
                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        fontSize: 12,
                        color: theme
                            .colorScheme
                            .primary,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // CARD
                    // ==================================================

                    AnimatedSwitcher(
                      duration:
                          const Duration(
                        milliseconds: 250,
                      ),

                      transitionBuilder:
                          (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child:
                              SlideTransition(
                            position:
                                Tween<Offset>(
                              begin:
                                  const Offset(
                                0.04,
                                0,
                              ),
                              end: Offset.zero,
                            ).animate(animation),

                            child: child,
                          ),
                        );
                      },

                      child: Container(
                        key: ValueKey(
                          _currentStep,
                        ),

                        padding:
                            const EdgeInsets.all(24),

                        decoration:
                            BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            24,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha:
                              0.06,
                              ),
                              blurRadius: 25,
                              offset:
                                  const Offset(
                                0,
                                8,
                              ),
                            ),
                          ],
                        ),

                        child:
                            _currentStep == 0
                                ? _buildPersonalStep()
                                : _currentStep == 1
                                    ? _buildUniversityStep()
                                    : _buildAccountStep(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // CONNEXION
                    // ==================================================

                    if (_currentStep == 0)
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [
                          Text(
                            'Vous avez déjà un compte ?',
                            style: TextStyle(
                              color: Colors
                                  .grey.shade700,
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                              );
                            },

                            child: const Text(
                              'Se connecter',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                    // ==================================================
                    // SÉCURITÉ
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons
                              .verified_user_outlined,
                          size: 15,
                          color:
                              Colors.grey.shade600,
                        ),

                        const SizedBox(width: 6),

                        Flexible(
                          child: Text(
                            'Vos informations restent confidentielles',
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors
                                  .grey.shade600,
                            ),
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
}