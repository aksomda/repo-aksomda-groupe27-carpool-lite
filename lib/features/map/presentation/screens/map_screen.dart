import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/route_map.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _MapAppBar(),
      body: RouteMap(
        origin: LatLng(
          3.8480,
          11.5020,
        ),
        destination: LatLng(
          3.8667,
          11.5167,
        ),
        showCurrentLocation: true,
        followUser: true,
        initialZoom: 14,
      ),
    );
  }
}

class _MapAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _MapAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Itinéraire'),
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);
}