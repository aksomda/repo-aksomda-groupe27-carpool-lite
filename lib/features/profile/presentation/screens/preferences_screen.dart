import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_screen.dart' show ProfileColors;

/// Écran "Mes préférences" : notifications, confidentialité et langue.
///
/// Les réglages sont persistés localement (SharedPreferences) : ce sont des
/// préférences d'affichage/comportement de l'application sur cet appareil,
/// pas des données de profil synchronisées côté serveur.
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

//enum AppLanguage { fr, en }

enum AppLanguage {
  french('fr', 'Français'),
  english('en', 'English');

  final String code;
  final String label;

  const AppLanguage(this.code, this.label);

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.french,
    );
  }
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  static const _keyPushNotifications = 'pref_push_notifications';
  static const _keyTripUpdates = 'pref_trip_updates';
  static const _keySharePhone = 'pref_share_phone';
  static const _keyDiscoverable = 'pref_discoverable';
  static const _keyLanguage = 'pref_language';

  bool _loading = true;
  bool _pushNotifications = true;
  bool _tripUpdates = true;
  bool _sharePhone = true;
  bool _discoverable = true;
  AppLanguage _language = AppLanguage.french;

  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _prefs = prefs;
      _pushNotifications = prefs.getBool(_keyPushNotifications) ?? true;
      _tripUpdates = prefs.getBool(_keyTripUpdates) ?? true;
      _sharePhone = prefs.getBool(_keySharePhone) ?? true;
      _discoverable = prefs.getBool(_keyDiscoverable) ?? true;
      _language = AppLanguage.fromCode(prefs.getString(_keyLanguage));
      _loading = false;
    });
  }

  Future<void> _setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  Future<void> _pickLanguage() async {
    final selected = await showModalBottomSheet<AppLanguage>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Langue',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: ProfileColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 12),
                RadioGroup<AppLanguage>(
                  groupValue: _language,
                  onChanged: (value) => Navigator.pop(context, value),
                  child: Column(
                    children: [
                      for (final lang in AppLanguage.values)
                        RadioListTile<AppLanguage>(
                          value: lang,
                          activeColor: ProfileColors.primary,
                          title: Text(lang.label),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && selected != _language) {
      setState(() => _language = selected);
      await _prefs?.setString(_keyLanguage, selected.code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              selected == AppLanguage.french
                  ? 'Langue définie sur Français'
                  : 'Language set to English',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.background,
      appBar: AppBar(title: const Text('Mes préférences')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SectionCard(
                  title: 'Notifications',
                  children: [
                    SwitchListTile(
                      activeThumbColor: ProfileColors.primary,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Notifications push'),
                      subtitle: const Text(
                        'Recevoir des alertes sur cet appareil',
                      ),
                      value: _pushNotifications,
                      onChanged: (value) {
                        setState(() => _pushNotifications = value);
                        _setBool(_keyPushNotifications, value);
                      },
                    ),
                    const Divider(height: 1, color: ProfileColors.border),
                    SwitchListTile(
                      activeThumbColor: ProfileColors.primary,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Mises à jour de trajets'),
                      subtitle: const Text(
                        'Réservations, confirmations, annulations',
                      ),
                      value: _tripUpdates,
                      onChanged: (value) {
                        setState(() => _tripUpdates = value);
                        _setBool(_keyTripUpdates, value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  title: 'Confidentialité',
                  children: [
                    SwitchListTile(
                      activeThumbColor: ProfileColors.primary,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Partager mon numéro'),
                      subtitle: const Text(
                        'Visible par les autres passagers d\'un trajet',
                      ),
                      value: _sharePhone,
                      onChanged: (value) {
                        setState(() => _sharePhone = value);
                        _setBool(_keySharePhone, value);
                      },
                    ),
                    const Divider(height: 1, color: ProfileColors.border),
                    SwitchListTile(
                      activeThumbColor: ProfileColors.primary,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Profil visible dans les recherches'),
                      subtitle: const Text(
                        'Apparaître comme conducteur ou passager disponible',
                      ),
                      value: _discoverable,
                      onChanged: (value) {
                        setState(() => _discoverable = value);
                        _setBool(_keyDiscoverable, value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  title: 'Langue',
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Langue de l\'application'),
                      subtitle: Text(_language.label),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: ProfileColors.darkBlue,
                      ),
                      onTap: _pickLanguage,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ProfileColors.mediumBlue,
                letterSpacing: 0.4,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
