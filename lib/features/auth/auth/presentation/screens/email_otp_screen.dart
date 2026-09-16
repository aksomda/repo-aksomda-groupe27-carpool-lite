import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';
import 'verify_student_screen.dart';

/// Écran de vérification par le lien officiel Firebase Authentication.
class EmailOtpScreen extends StatefulWidget {
  final AuthProvider authProvider;

  const EmailOtpScreen({super.key, required this.authProvider});

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  bool _linkSent = false;

  @override
  void initState() {
    super.initState();
    _sendVerificationLink();
  }

  Future<void> _sendVerificationLink() async {
    final bool success = await widget.authProvider.sendEmailVerification();
    if (!mounted) return;
    setState(() => _linkSent = success);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.authProvider.errorMessage ??
                'Impossible d\'envoyer le lien de vérification.',
          ),
        ),
      );
    }
  }

  Future<void> _checkVerification() async {
    final bool success = await widget.authProvider.checkEmailVerification();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email vérifié avec succès.')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => VerifyStudentScreen(
            authProvider: widget.authProvider,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.authProvider.errorMessage ??
                'Le lien n’a pas encore été validé. Ouvrez le lien reçu, puis '
                    'revenez ici et appuyez sur ce bouton.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = widget.authProvider.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Vérification de l\'email')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 64),
              const SizedBox(height: 24),
              Text(
                _linkSent
                    ? 'Un lien de validation Firebase a été envoyé à '
                        '${widget.authProvider.user?.email ?? "votre adresse email"}. '
                        'Ouvrez ce lien, puis revenez dans l’application.'
                    : 'Envoi du lien de validation en cours...',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _checkVerification,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                    : const Text('J’ai validé mon adresse e-mail'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: isLoading ? null : _sendVerificationLink,
                child: const Text('Renvoyer le lien'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
