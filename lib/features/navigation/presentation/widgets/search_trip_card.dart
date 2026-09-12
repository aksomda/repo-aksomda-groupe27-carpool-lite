import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class SearchTripCard extends StatefulWidget {
  final VoidCallback? onSearch;

  const SearchTripCard({
    super.key,
    this.onSearch,
  });

  @override
  State<SearchTripCard> createState() =>
      _SearchTripCardState();
}

class _SearchTripCardState
    extends State<SearchTripCard> {

  final TextEditingController departureController =
  TextEditingController();

  final TextEditingController arrivalController =
  TextEditingController();

  DateTime selectedDate = DateTime.now();

  int passengers = 1;

  @override
  void dispose() {
    departureController.dispose();
    arrivalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  void _swapLocations() {
    final departure = departureController.text;
    final arrival = arrivalController.text;

    departureController.text = arrival;
    arrivalController.text = departure;

    setState(() {});
  }

  void _selectPassengers() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Nombre de passagers',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: passengers > 1
                            ? () {
                          setModalState(() {
                            passengers--;
                          });

                          setState(() {});
                        }
                            : null,
                        icon: const Icon(
                          Icons.remove_circle_outline,
                        ),
                        color: AppColors.primary,
                        iconSize: 36,
                      ),

                      const SizedBox(width: 25),

                      Text(
                        '$passengers',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),

                      const SizedBox(width: 25),

                      IconButton(
                        onPressed: passengers < 8
                            ? () {
                          setModalState(() {
                            passengers++;
                          });

                          setState(() {});
                        }
                            : null,
                        icon: const Icon(
                          Icons.add_circle_outline,
                        ),
                        color: AppColors.primary,
                        iconSize: 36,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize:
                        const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Valider',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate() {
    final now = DateTime.now();

    if (selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day) {
      return "Aujourd'hui";
    }

    return '${selectedDate.day.toString().padLeft(2, '0')}/'
        '${selectedDate.month.toString().padLeft(2, '0')}/'
        '${selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 25,
        top: 24,
        right: 25,
        bottom: 30
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // TITRE
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 29,
                ),
              ),

              const SizedBox(width: 15),

              const Text(
                'Où allez-vous ?',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // DEPART
          _LocationField(
            controller: departureController,
            title: 'Départ',
            hint: 'Ex. : Université de Yaoundé I',
            icon: Icons.location_on,
            color: AppColors.primary,
          ),

          // SWAP
          Transform.translate(
            offset: const Offset(10, -25),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _swapLocations,
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F6FF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: const Icon(
                    Icons.swap_vert_rounded,
                    color: AppColors.textDark,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),

          // ARRIVEE
          Transform.translate(
            offset: const Offset(0, -50),
            child: _LocationField(
              controller: arrivalController,
              title: 'Arrivée',
              hint: 'Ex. : Nsimallen, Mfoundi, etc.',
              icon: Icons.location_on,
              color: AppColors.secondary,
            ),
          ),


          // DATE + PASSAGERS
          Transform.translate(
            offset: const Offset(0, -30),
            child: Row(
              children: [
                Expanded(
                  child: _InfoSelector(
                    icon: Icons.calendar_month_outlined,
                    title: 'Date',
                    value: _formatDate(),
                    onTap: _selectDate,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _InfoSelector(
                    icon: Icons.people_alt_outlined,
                    title: 'Passagers',
                    value: '$passengers',
                    onTap: _selectPassengers,
                    showArrow: true,
                  ),
                ),
              ],
            ),
          ),


          const SizedBox(height: 18),

          // BOUTON RECHERCHE
          Transform.translate(
            offset: const Offset(0, -30),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                onPressed: widget.onSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(35),
                  ),
                ),
                icon: const Icon(
                  Icons.search,
                  size: 30,
                ),
                label: const Text(
                  'Rechercher un trajet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String hint;
  final IconData icon;
  final Color color;

  const _LocationField({
    required this.controller,
    required this.title,
    required this.hint,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 45),
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),

          Icon(
            icon,
            color: color,
            size: 34,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textGrey,
                  ),
                ),

                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textGrey,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                    EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class _InfoSelector extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final bool showArrow;

  const _InfoSelector({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 30,
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),

            if (showArrow)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textDark,
                size: 28,
              )
            else
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textDark,
                size: 25,
              ),
          ],
        ),
      ),
    );
  }
}