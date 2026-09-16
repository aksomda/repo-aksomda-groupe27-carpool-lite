import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/google_maps_datasource.dart';
import '../../data/repositories_impl/map_repository_impl.dart';
import '../../domain/repositories/map_repository.dart';
import '../../domain/usecases/get_route.dart';

final googleMapsDataSourceProvider =
Provider<GoogleMapsDataSource>((ref) {
  const apiKey = String.fromEnvironment(
    'MAPS_API_KEY',
  );

  if (apiKey.isEmpty) {
    throw StateError(
      'MAPS_API_KEY est introuvable. '
          'Vérifie android/local.properties '
          'et la configuration Gradle.',
    );
  }

  final dataSource = GoogleMapsDataSource(
    apiKey: apiKey,
  );

  ref.onDispose(dataSource.dispose);

  return dataSource;
});

final mapRepositoryProvider =
Provider<MapRepository>((ref) {
  return MapRepositoryImpl(
    dataSource: ref.watch(
      googleMapsDataSourceProvider,
    ),
  );
});

final getRouteProvider =
Provider<GetRoute>((ref) {
  return GetRoute(
    ref.watch(mapRepositoryProvider),
  );
});