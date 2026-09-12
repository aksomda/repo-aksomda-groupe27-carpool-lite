import 'package:flutter/material.dart';

import 'publish_trip_page.dart';
import 'search_trips_page.dart';
import 'trip_history_page.dart';

class TripsMainPage extends StatefulWidget {
  const TripsMainPage({super.key});

  @override
  State<TripsMainPage> createState() => _TripsMainPageState();
}

class _TripsMainPageState extends State<TripsMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    PublishTripPage(),
    SearchTripsPage(),
    TripHistoryPage(userId: 'TEMP_USER_ID'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add_road), label: 'Publier'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Rechercher'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
        ],
      ),
    );
  }
}
