import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

/// Écran de vérification du statut étudiant.
///
/// Affiché juste après l'inscription : l'utilisateur saisit son
/// identifiant étudiant (studentId) afin de confirmer son statut
/// auprès de l'université.
class VerifyStudentScreen extends StatefulWidget {
  final AuthProvider authProvider;

  const VerifyStudentScreen({
    super.key,
    required this.authProvider,
  });

  @override
  State<VerifyStudentScreen> createState() => _VerifyStudentScreenState();
}

class _VerifyStudentScreenState extends State<VerifyStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool success = await widget.authProvider.verifyStudent(
      studentId: _studentIdController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Statut étudiant vérifié avec succès.'),
        ),
      );

      // Une fois vérifié, on redirige vers l'accueil
      // temporaire de CarPool Lite.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const _VerificationSuccessScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.authProvider.errorMessage ??
                'Identifiant étudiant introuvable ou invalide.',
          ),
        ),
      );
    }
  }

  String? _validateStudentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer votre identifiant étudiant.';
    }

    if (value.trim().length < 3) {
      return 'L’identifiant étudiant semble trop court.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification étudiant'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                const Icon(
                  Icons.verified_user_outlined,
                  size: 70,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Confirmez votre statut étudiant',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Entrez votre identifiant étudiant pour finaliser '
                  'la création de votre compte CarPool Lite.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 30),

                AuthTextField(
                  controller: _studentIdController,
                  label: 'Identifiant étudiant',
                  hint: 'Ex : ETU2026-00123',
                  prefixIcon: Icons.badge_outlined,
                  validator: _validateStudentId,
                ),

                const SizedBox(height: 28),

                AnimatedBuilder(
                  animation: widget.authProvider,
                  builder: (context, child) {
                    if (widget.authProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _verify,
                        child: const Text(
                          'Vérifier mon statut',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const _VerificationSuccessScreen(),
                        ),
                      );
                    },
                    child: const Text('Vérifier plus tard'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Écran de bienvenue affiché après vérification (ou report de la
/// vérification). Combine la maquette de marque de CarPool Lite avec le
/// message de bienvenue et un accès direct à l'espace étudiant.
class _VerificationSuccessScreen extends StatelessWidget {
  const _VerificationSuccessScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ============================================================
          // MAQUETTE / LOGO
          // ============================================================
          Expanded(
            flex: 6,
            child: Image.asset(
              'assets/splash/splash_screen.png',
              width: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // ============================================================
          // MESSAGE DE BIENVENUE + ACCÈS À L'APPLICATION
          // ============================================================
          Expanded(
            flex: 4,
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 24,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Bienvenue sur CarPool Lite !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11224E),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Votre compte est prêt. Trouvez ou proposez un '
                      'trajet avec d\'autres étudiants dès maintenant.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text(
                          'Accéder à mon espace',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF1468F5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}