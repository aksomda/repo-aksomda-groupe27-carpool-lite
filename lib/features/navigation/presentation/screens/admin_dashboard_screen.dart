import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/firebase/firebase_status.dart';
import '../../../formations/data/repositories/formation_repository.dart';
import '../../../levels/presentation/pages/add_edit_academic_level_page.dart';
import '../../../formations/presentation/pages/add_edit_formation_page.dart';
import '../../../universities/data/models/university_model.dart';
import '../../../universities/data/repositories/university_repository.dart';
import '../../../universities/presentation/pages/add_edit_university_page.dart';

const List<String> _kJoursFr = [
  'Lundi',
  'Mardi',
  'Mercredi',
  'Jeudi',
  'Vendredi',
  'Samedi',
  'Dimanche',
];

const List<String> _kMoisFr = [
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

String _formatDateFr(DateTime date) {
  final jour = _kJoursFr[date.weekday - 1];
  final mois = _kMoisFr[date.month - 1];
  return '$jour ${date.day} $mois ${date.year}';
}

String _formatHeure(DateTime date) {
  final h = date.hour.toString().padLeft(2, '0');
  final m = date.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// Tableau de bord de l'administrateur, affiché comme page d'accueil sur
/// [AppDashboardScreen] lorsque l'utilisateur connecté a le rôle admin.
///
/// Les compteurs (utilisateurs, universités, formations) sont branchés sur
/// les données réelles Firestore. Deux éléments du visuel d'origine n'ont en
/// revanche aucune source de données dans le projet actuel et sont donc
/// affichés de façon honnête plutôt que simulés :
/// - le nombre de trajets et la liste "Trajets récents" : le module Trajets
///   (lib/features/trips) n'est encore qu'un squelette, aucune collection
///   Firestore 'trips' n'est alimentée ;
/// - le graphique d'évolution sur 7 jours : ni les utilisateurs ni les
///   trajets n'enregistrent de date de création exploitable pour tracer un
///   historique.
class AdminDashboardBody extends StatefulWidget {
  final String userName;

  const AdminDashboardBody({super.key, required this.userName});

  @override
  State<AdminDashboardBody> createState() => _AdminDashboardBodyState();
}

class _AdminDashboardBodyState extends State<AdminDashboardBody> {
  late DateTime _now;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => setState(() => _now = DateTime.now()),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _GreetingCard(userName: widget.userName, now: _now),
          const SizedBox(height: 16),
          const _StatsGrid(),
          const SizedBox(height: 16),
          const _ActiveReportsCard(),
          const SizedBox(height: 16),
          const _EvolutionCard(),
          const SizedBox(height: 16),
          const _UniversityBreakdownCard(),
          const SizedBox(height: 24),
          const _QuickActions(),
          const SizedBox(height: 24),
          const _RecentTripsSection(),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final String userName;
  final DateTime now;

  const _GreetingCard({required this.userName, required this.now});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2952E3), Color(0xFF3B6BF5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour ${userName.isEmpty ? 'Admin' : userName} 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Voici un aperçu de l'activité de votre plateforme aujourd'hui.",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(text: _formatDateFr(now), filled: false),
                    _Pill(text: _formatHeure(now), filled: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text('🎓', style: TextStyle(fontSize: 32)),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool filled;

  const _Pill({required this.text, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? Colors.white.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Grille 2x2 des indicateurs clés. Chaque carte lit un flux réel.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _UsersStatCard(),
        _TripsStatCard(),
        _CountStatCard(
          icon: Icons.account_balance,
          color: const Color(0xFFF59E0B),
          label: 'Universités',
          stream: UniversityRepository.instance.getUniversities(),
          count: (list) => list.length,
        ),
        _CountStatCard(
          icon: Icons.school,
          color: const Color(0xFF10B981),
          label: 'Formations',
          stream: FormationRepository.instance.getFormations(),
          count: (list) => list.length,
        ),
      ],
    );
  }
}

class _StatCardShell extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String caption;

  const _StatCardShell({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 18),
          ),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(caption, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

/// Nombre total d'utilisateurs inscrits (collection `users`, temps réel).
class _UsersStatCard extends StatelessWidget {
  const _UsersStatCard();

  @override
  Widget build(BuildContext context) {
    if (!FirebaseStatus.available) {
      return const _StatCardShell(
        icon: Icons.people_alt,
        color: Color(0xFF3B82F6),
        value: '—',
        label: 'Utilisateurs inscrits',
        caption: 'Firebase non configuré',
      );
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        final total = snapshot.data?.docs.length;
        return _StatCardShell(
          icon: Icons.people_alt,
          color: const Color(0xFF3B82F6),
          value: total?.toString() ?? '…',
          label: 'Utilisateurs inscrits',
          caption: 'Total actuellement inscrits',
        );
      },
    );
  }
}

/// Nombre de trajets publiés (collection `trips`, temps réel).
///
/// Le module Trajets n'écrit encore dans aucune collection Firestore (voir
/// lib/features/trips) : ce compteur affichera 0 jusqu'à ce qu'il soit
/// implémenté, mais fonctionnera automatiquement dès que ce sera le cas.
class _TripsStatCard extends StatelessWidget {
  const _TripsStatCard();

  @override
  Widget build(BuildContext context) {
    if (!FirebaseStatus.available) {
      return const _StatCardShell(
        icon: Icons.directions_car,
        color: Color(0xFF10B981),
        value: '—',
        label: 'Trajets publiés',
        caption: 'Firebase non configuré',
      );
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('trips').snapshots(),
      builder: (context, snapshot) {
        final total = snapshot.data?.docs.length;
        return _StatCardShell(
          icon: Icons.directions_car,
          color: const Color(0xFF10B981),
          value: total?.toString() ?? '…',
          label: 'Trajets publiés',
          caption: 'Module Trajets à connecter',
        );
      },
    );
  }
}

/// Carte générique pour un compteur basé sur un flux déjà exposé par un
/// repository existant (universités, formations...).
class _CountStatCard<T> extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final Stream<List<T>> stream;
  final int Function(List<T>) count;

  const _CountStatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.stream,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snapshot) {
        final value = snapshot.hasData ? count(snapshot.data!).toString() : '…';
        return _StatCardShell(
          icon: icon,
          color: color,
          value: value,
          label: label,
          caption: 'Total actuellement',
        );
      },
    );
  }
}

/// Signalements actifs. Aucun module de modération n'existe encore dans le
/// projet : la collection `reports` n'est alimentée nulle part. La carte lit
/// tout de même ce flux en direct (elle affichera 0 pour l'instant) afin de
/// fonctionner automatiquement le jour où une fonctionnalité de signalement
/// sera ajoutée.
class _ActiveReportsCard extends StatelessWidget {
  const _ActiveReportsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Signalements actifs', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 4),
                if (!FirebaseStatus.available)
                  const Text('—', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))
                else
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('reports').snapshots(),
                    builder: (context, snapshot) {
                      final total = snapshot.data?.docs.length ?? 0;
                      return Text(
                        total.toString(),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                const Text(
                  'Module de modération à mettre en place',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Historique "Évolution des trajets et utilisateurs".
///
/// Ni les utilisateurs (`users`) ni les trajets (`trips`, pas encore
/// implémenté) n'enregistrent de date de création exploitable aujourd'hui :
/// il n'existe donc pas de donnée réelle sur laquelle tracer un historique
/// jour par jour. Plutôt que de simuler une tendance, la carte l'indique
/// clairement. Pour activer ce graphique plus tard : ajouter un champ
/// `createdAt` (Timestamp serveur) sur les documents `users` et `trips`,
/// puis regrouper les documents par jour sur les 7 derniers jours.
class _EvolutionCard extends StatelessWidget {
  const _EvolutionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Évolution des trajets et utilisateurs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart, color: Colors.grey.shade400, size: 32),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "Historique indisponible : aucune date de création n'est encore\n"
                      "enregistrée sur les utilisateurs ou les trajets.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const List<Color> _kPalette = [
  Color(0xFF2952E3),
  Color(0xFF10B981),
  Color(0xFF34D399),
  Color(0xFFF59E0B),
  Color(0xFF9CA3AF),
];

/// Répartition réelle des utilisateurs par université (calculée à partir de
/// `users.universityId`, résolu en nom via [UniversityRepository]).
class _UniversityBreakdownCard extends StatelessWidget {
  const _UniversityBreakdownCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Répartition par université', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          if (!FirebaseStatus.available)
            const Text('Firebase non configuré.', style: TextStyle(color: Colors.grey))
          else
            StreamBuilder<List<UniversityModel>>(
              stream: UniversityRepository.instance.getUniversities(),
              builder: (context, uniSnapshot) {
                final universities = uniSnapshot.data ?? [];
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, userSnapshot) {
                    final docs = userSnapshot.data?.docs ?? [];
                    if (!userSnapshot.hasData || universities.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final counts = <String, int>{};
                    for (final doc in docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final id = data['universityId'] as String?;
                      if (id == null || id.isEmpty) continue;
                      counts[id] = (counts[id] ?? 0) + 1;
                    }
                    final total = counts.values.fold<int>(0, (a, b) => a + b);

                    if (total == 0) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "Aucun utilisateur n'est encore rattaché à une université.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    final nameById = {for (final u in universities) u.id: u.name};
                    final entries = counts.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));

                    // Les 4 plus grosses universités, le reste regroupé.
                    final top = entries.take(4).toList();
                    final rest = entries.skip(4).fold<int>(0, (a, e) => a + e.value.toInt());

                    final segments = <MapEntry<String, int>>[
                      ...top.map((e) => MapEntry(nameById[e.key] ?? 'Université', e.value)),
                      if (rest > 0) MapEntry('Autres', rest),
                    ];

                    return Row(
                      children: [
                        SizedBox(
                          width: 96,
                          height: 96,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 30,
                                  sections: [
                                    for (var i = 0; i < segments.length; i++)
                                      PieChartSectionData(
                                        value: segments[i].value.toDouble(),
                                        color: _kPalette[i % _kPalette.length],
                                        showTitle: false,
                                        radius: 18,
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${universities.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  const Text('Univ.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: [
                              for (var i = 0; i < segments.length; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(color: _kPalette[i % _kPalette.length], shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          segments[i].key,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      Text(
                                        '${(segments[i].value / total * 100).round()}%',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      _QuickAction(
        icon: Icons.add,
        label: 'Ajouter classe',
        onTap: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(builder: (_) => const AddEditAcademicLevelPage()),
        ),
      ),
      _QuickAction(
        icon: Icons.add,
        label: 'Ajouter formation',
        onTap: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(builder: (_) => const AddEditFormationPage()),
        ),
      ),
      _QuickAction(
        icon: Icons.add,
        label: 'Ajouter univ.',
        onTap: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(builder: (_) => const AddEditUniversityPage()),
        ),
      ),
      _QuickAction(
        icon: Icons.notifications_outlined,
        label: 'Notifier',
        onTap: (ctx) => ctx.push('/notifications'),
      ),
      _QuickAction(
        icon: Icons.people_alt_outlined,
        label: 'Gérer utilisateurs',
        onTap: (ctx) => ctx.push('/admin/users'),
      ),
      _QuickAction(
        icon: Icons.directions_car_outlined,
        label: 'Voir trajets',
        onTap: (ctx) => ctx.push('/trips/search'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Actions Rapides', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.05,
          children: actions,
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final void Function(BuildContext) onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onTap(context),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: const Color(0xFF2952E3).withValues(alpha: 0.1), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(icon, color: const Color(0xFF2952E3), size: 18),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Liste "Trajets récents". Aucun trajet n'est encore publié nulle part dans
/// l'application (module Trajets non implémenté) : cette section lit tout
/// de même la collection `trips` en direct et affiche un état vide honnête
/// tant qu'elle n'est pas alimentée, plutôt que des exemples inventés.
class _RecentTripsSection extends StatelessWidget {
  const _RecentTripsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Trajets récents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton(
              onPressed: () => context.push('/trips/search'),
              child: const Text('Voir tout →'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!FirebaseStatus.available)
          const Text('Firebase non configuré.', style: TextStyle(color: Colors.grey))
        else
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('trips')
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "Aucun trajet publié pour le moment — le module Trajets "
                    "n'est pas encore connecté à Firestore.",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return Column(
                children: [
                  for (final doc in docs)
                    _TripTile(data: doc.data() as Map<String, dynamic>),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _TripTile extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TripTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final driverName = (data['driverName'] as String?) ?? 'Conducteur';
    final origin = (data['origin'] as String?) ?? '?';
    final destination = (data['destination'] as String?) ?? '?';
    final status = (data['status'] as String?) ?? 'inconnu';

    Color badgeColor;
    switch (status.toLowerCase()) {
      case 'en_cours':
      case 'en cours':
        badgeColor = const Color(0xFF10B981);
        break;
      case 'termine':
      case 'terminé':
        badgeColor = const Color(0xFF3B82F6);
        break;
      case 'annule':
      case 'annulé':
        badgeColor = const Color(0xFFEF4444);
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(driverName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('$origin → $destination', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(color: badgeColor, fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
