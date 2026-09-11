import 'package:flutter/material.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_avatar.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AuthProvider authProvider;
  final ProfileProvider profileProvider;

  const ProfileScreen({
    super.key,
    required this.authProvider,
    required this.profileProvider,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final uid = widget.authProvider.user?.uid;
    if (uid != null) {
      widget.profileProvider.loadProfile(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.profileProvider,
      builder: (context, _) {
        final profile = widget.profileProvider.profile;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mon profil'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Déconnexion',
                onPressed: () => widget.authProvider.signOut(),
              ),
            ],
          ),
          body: widget.profileProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.profileProvider.errorMessage != null
                  ? Center(child: Text(widget.profileProvider.errorMessage!))
                  : profile == null
                      ? const Center(child: Text('Aucun profil.'))
                      : ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            Center(
                              child: ProfileAvatar(name: profile.name, radius: 48),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                profile.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Center(
                              child: Text(
                                profile.email,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ListTile(
                              leading: const Icon(Icons.phone),
                              title: const Text('Téléphone'),
                              subtitle: Text(profile.phone),
                            ),
                            ListTile(
                              leading: const Icon(Icons.wc),
                              title: const Text('Sexe'),
                              subtitle: Text(
                                profile.sex == Sex.homme ? 'Homme' : 'Femme',
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                profile.isVerified
                                    ? Icons.verified
                                    : Icons.hourglass_empty,
                                color:
                                    profile.isVerified ? Colors.green : Colors.orange,
                              ),
                              title: const Text('Statut étudiant'),
                              subtitle: Text(
                                profile.isVerified ? 'Vérifié' : 'Non vérifié',
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EditProfileScreen(
                                      profileProvider: widget.profileProvider,
                                      profile: profile,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Modifier mon profil'),
                            ),
                          ],
                        ),
        );
      },
    );
  }
}