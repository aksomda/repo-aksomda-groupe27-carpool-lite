// lib/features/navigation/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';


class HomeScreen extends StatefulWidget {
  final AuthProvider authProvider;

  const HomeScreen({super.key, required this.authProvider});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _departureController = TextEditingController();
  final _arrivalController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int _passengers = 1;

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    super.dispose();
  }

  void _swapDepartureAndArrival() {
    setState(() {
      final tmp = _departureController.text;
      _departureController.text = _arrivalController.text;
      _arrivalController.text = tmp;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String get _formattedDate {
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    if (isToday) return "Aujourd'hui";
    return '${_selectedDate.day.toString().padLeft(2, '0')}/'
        '${_selectedDate.month.toString().padLeft(2, '0')}/'
        '${_selectedDate.year}';
  }

  void _changePassengers(int delta) {
    setState(() {
      _passengers = (_passengers + delta).clamp(1, 8);
    });
  }

  void _searchTrip() {
    // TODO(équipe): une fois `TripProvider`/`SearchTripsUseCase` prêts,
    // transmettre départ/arrivée/date/passagers à l'écran de recherche
    // (ex. via des query params GoRouter) au lieu d'une simple navigation.
    context.push('/trips/search');
  }

  void _comingSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authProvider.user;
    final firstName = (user?.name ?? '').split(' ').firstOrNull ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          children: [
            _HomeHeader(onNotificationsTap: () => context.push('/notifications'), onProfileTap: () => context.push('/profile')),
            const SizedBox(height: 22),
            Text(
              'Bonjour ${firstName.isEmpty ? '!' : '$firstName !'}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Prête pour un nouveau trajet ?',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            const _DestinationBanner(),
            const SizedBox(height: 18),
            _SearchCard(
              departureController: _departureController,
              arrivalController: _arrivalController,
              formattedDate: _formattedDate,
              passengers: _passengers,
              onSwap: _swapDepartureAndArrival,
              onPickDate: _pickDate,
              onIncrementPassengers: () => _changePassengers(1),
              onDecrementPassengers: () => _changePassengers(-1),
              onSearch: _searchTrip,
            ),
            const SizedBox(height: 26),
            const Text(
              'Trajets disponibles',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            // TODO(équipe): remplacer `_sampleTrips` par le résultat de
            // TripProvider dès que le module trips sera implémenté.
            for (final trip in _sampleTrips) ...[
              _TripCard(trip: trip, onTap: () => _comingSoon('Détail du trajet bientôt disponible.')),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _HomeBottomNavBar(
        onTripTap: () => context.push('/trips/search'),
        onMessageTap: () => context.push('/chat'),
        onProfileTap: () => context.push('/profile'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/trips/publish'),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

// ================================================================
// EN-TÊTE — logo, notifications, avatar
// ================================================================

class _HomeHeader extends StatelessWidget {
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  const _HomeHeader({required this.onNotificationsTap, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/logo_carpoollite.png', width: 38, height: 38, fit: BoxFit.cover),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CarPool Lite',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.navy),
              ),
              Text(
                'Covoiturage pour étudiants',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: onNotificationsTap,
              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.navy),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onProfileTap,
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.inputFill,
            child: Icon(Icons.person, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// BANNIÈRE — "Ensemble vers vos destinations !"
// ================================================================

class _DestinationBanner extends StatelessWidget {
  const _DestinationBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFDCEBFF), Color(0xFFEFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.navy, height: 1.25),
                children: [
                  TextSpan(text: 'Ensemble\n', style: TextStyle(color: AppColors.primary)),
                  TextSpan(text: 'vers vos\ndestinations !'),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primary, size: 34),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// CARTE DE RECHERCHE — "Où allez-vous ?"
// ================================================================

class _SearchCard extends StatelessWidget {
  final TextEditingController departureController;
  final TextEditingController arrivalController;
  final String formattedDate;
  final int passengers;
  final VoidCallback onSwap;
  final VoidCallback onPickDate;
  final VoidCallback onIncrementPassengers;
  final VoidCallback onDecrementPassengers;
  final VoidCallback onSearch;

  const _SearchCard({
    required this.departureController,
    required this.arrivalController,
    required this.formattedDate,
    required this.passengers,
    required this.onSwap,
    required this.onPickDate,
    required this.onIncrementPassengers,
    required this.onDecrementPassengers,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Où allez-vous ?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),

          // Champs Départ / Arrivée avec repère visuel (points + trait) et
          // bouton d'inversion, comme dans la maquette.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _RouteField(
                      dotColor: AppColors.primary,
                      label: 'DÉPART',
                      controller: departureController,
                      hint: 'Ex. : Université de Yaoundé I',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 6,
                            child: Column(
                              children: List.generate(
                                3,
                                (_) => const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 1.5),
                                  child: SizedBox(width: 2, height: 2, child: DecoratedBox(decoration: BoxDecoration(color: AppColors.border, shape: BoxShape.circle))),
                                ),
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                    _RouteField(
                      dotColor: AppColors.accentYellow,
                      label: 'ARRIVÉE',
                      controller: arrivalController,
                      hint: 'Ex. : Nsimalen, Mfoundi, etc.',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onSwap,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: AppColors.inputFill, shape: BoxShape.circle),
                  child: const Icon(Icons.swap_vert_rounded, color: AppColors.primary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Date / Passagers
          Row(
            children: [
              Expanded(
                child: _MiniField(
                  icon: Icons.calendar_today_outlined,
                  label: 'DATE',
                  value: formattedDate,
                  onTap: onPickDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PassengerField(
                  count: passengers,
                  onIncrement: onIncrementPassengers,
                  onDecrement: onDecrementPassengers,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSearch,
              icon: const Icon(Icons.search),
              label: const Text('Rechercher un trajet'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteField extends StatelessWidget {
  final Color dotColor;
  final String label;
  final TextEditingController controller;
  final String hint;

  const _RouteField({required this.dotColor, required this.label, required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.inputFill,
              labelText: label,
              labelStyle: const TextStyle(fontSize: 11, letterSpacing: 0.4, color: AppColors.textSecondary),
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _MiniField({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(fontSize: 10, letterSpacing: 0.4, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _PassengerField extends StatelessWidget {
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _PassengerField({required this.count, required this.onIncrement, required this.onDecrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people_alt_outlined, size: 14, color: AppColors.primary),
              SizedBox(width: 6),
              Text('PASSAGERS', style: TextStyle(fontSize: 10, letterSpacing: 0.4, color: AppColors.textSecondary)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$count', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Row(
                children: [
                  _StepperButton(icon: Icons.remove, onTap: onDecrement),
                  const SizedBox(width: 4),
                  _StepperButton(icon: Icons.add, onTap: onIncrement),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 14, color: AppColors.primary),
      ),
    );
  }
}

// ================================================================
// LISTE DES TRAJETS DISPONIBLES
// ================================================================

class _TripPreview {
  final String driverName;
  final String role;
  final int seats;
  final double rating;
  final String time;
  final String duration;
  final String price;

  const _TripPreview({
    required this.driverName,
    required this.role,
    required this.seats,
    required this.rating,
    required this.time,
    required this.duration,
    required this.price,
  });
}

const _sampleTrips = [
  _TripPreview(driverName: 'Chantal M.', role: 'Étudiante', seats: 4, rating: 4.8, time: '07:30', duration: '2h10', price: '1 500 FCFA'),
  _TripPreview(driverName: 'Kevin T.', role: 'Étudiant', seats: 3, rating: 4.6, time: '08:00', duration: '2h00', price: '1 200 FCFA'),
  _TripPreview(driverName: 'Sandra B.', role: 'Étudiante', seats: 4, rating: 4.9, time: '08:15', duration: '2h30', price: '1 500 FCFA'),
];

class _TripCard extends StatelessWidget {
  final _TripPreview trip;
  final VoidCallback onTap;

  const _TripCard({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.inputFill,
              child: Text(
                trip.driverName.isNotEmpty ? trip.driverName[0] : '?',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          trip.driverName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _RatingBadge(rating: trip.rating),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${trip.role} • ${trip.seats} places',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      children: [
                        TextSpan(text: '${trip.time} · ${trip.duration} · '),
                        TextSpan(
                          text: trip.price,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.rating.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.rating),
          const SizedBox(width: 3),
          Text('$rating', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navy)),
        ],
      ),
    );
  }
}

// ================================================================
// NAVIGATION DU BAS — Accueil / Trajet / Message / Profil
// ================================================================

class _HomeBottomNavBar extends StatelessWidget {
  final VoidCallback onTripTap;
  final VoidCallback onMessageTap;
  final VoidCallback onProfileTap;

  const _HomeBottomNavBar({required this.onTripTap, required this.onMessageTap, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: AppColors.surface,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const _NavItem(icon: Icons.home_rounded, label: 'Accueil', selected: true),
            _NavItem(icon: Icons.directions_car_outlined, label: 'Trajet', onTap: onTripTap),
            const SizedBox(width: 40), // espace réservé au bouton flottant central
            _NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Message', onTap: onMessageTap),
            _NavItem(icon: Icons.person_outline_rounded, label: 'Profil', onTap: onProfileTap),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _NavItem({required this.icon, required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}