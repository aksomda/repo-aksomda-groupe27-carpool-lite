import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/universities/data/datasources/university_remote_datasource.dart';
import 'package:repo_aksomda_groupe27_carpool_lite/features/universities/data/models/university_model.dart';

void addNewUniversityExample() async {
  // Initialisation de la source de données avec l'instance Firestore
  final dataSource = UniversityRemoteDataSource(
    firestore: FirebaseFirestore.instance,
  );

  // Création du modèle avec les informations de l'université
  final newUni = UniversityModel(
    id: '', // Laissé vide si .add() génère l'ID automatiquement
    name: 'Université Joseph Ki-Zerbo',
    city: 'Ouagadougou',
    latitude: 12.3714,
    longitude: -1.5197,
    address: 'Avenue de l\'Indépendance',
  );

  try {
    // Sauvegarde dans Firestore
    await dataSource.createUniversity(newUni);
    debugPrint('Université enregistrée avec succès dans Firestore !');
  } catch (e) {
    debugPrint('Erreur : $e');
  }
}
