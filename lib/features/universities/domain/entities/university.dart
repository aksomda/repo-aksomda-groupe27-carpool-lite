class University {
  final String id;
  final String name;
  final String city;
  // Champs texte libres pour accepter des formats tels que
  // "11,20926° N" ou "-4,41762° O", et pas uniquement des décimaux bruts.
  final String latitude;
  final String longitude;
  final String address;

  University({
    required this.id,
    required this.name,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}
