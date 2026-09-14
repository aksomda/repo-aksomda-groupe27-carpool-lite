import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/profile_model.dart';

class ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ProfileRemoteDataSource({
    required this.firestore,
    FirebaseStorage? storage,
  }) : storage = storage ?? FirebaseStorage.instance;

  // ============================================================
  // RÉCUPÉRER LE PROFIL
  // ============================================================

  Future<ProfileModel> getProfile(String uid) async {
    try {
      debugPrint('👤 Chargement du profil : $uid');

      final doc = await firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw Exception('Profil introuvable.');
      }

      debugPrint('✅ Profil récupéré');

      return ProfileModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      debugPrint('❌ Erreur Firebase lors du chargement du profil');
      debugPrint('Code : ${e.code}');
      debugPrint('Message : ${e.message}');

      throw Exception(
        'Impossible de charger le profil : ${e.message}',
      );
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement du profil : $e');

      throw Exception(
        'Impossible de charger le profil : $e',
      );
    }
  }

  // ============================================================
  // MODIFIER LE PROFIL
  // ============================================================

  Future<void> updateProfile(ProfileModel profile) async {
    try {
      debugPrint('✏️ Mise à jour du profil : ${profile.uid}');

      await firestore
          .collection('users')
          .doc(profile.uid)
          .update(profile.toFirestoreUpdate());

      debugPrint('✅ Profil mis à jour avec succès');
    } on FirebaseException catch (e) {
      debugPrint('❌ Erreur Firebase lors de la mise à jour');
      debugPrint('Code : ${e.code}');
      debugPrint('Message : ${e.message}');

      throw Exception(
        'Impossible de mettre à jour le profil : ${e.message}',
      );
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour du profil : $e');

      throw Exception(
        'Impossible de mettre à jour le profil : $e',
      );
    }
  }

  // ============================================================
  // MODIFIER LA PHOTO DE PROFIL
  // ============================================================

  Future<String> updatePhoto(
    String uid,
    Uint8List bytes,
  ) async {
    try {
      debugPrint('==========================================');
      debugPrint('📸 DÉBUT UPLOAD PHOTO');
      debugPrint('👤 UID : $uid');
      debugPrint('📦 Taille : ${bytes.length} bytes');

      if (bytes.isEmpty) {
        throw Exception('L’image sélectionnée est vide.');
      }

      // ----------------------------------------------------------
      // 1. Référence Firebase Storage
      // ----------------------------------------------------------

      final ref = storage
          .ref()
          .child('profile_photos')
          .child('$uid.jpg');

      debugPrint(
        '☁️ Chemin Storage : profile_photos/$uid.jpg',
      );

      // ----------------------------------------------------------
      // 2. Upload de l'image
      // ----------------------------------------------------------

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );

      debugPrint('⏳ Upload vers Firebase Storage...');

      await ref.putData(
        bytes,
        metadata,
      );

      debugPrint('✅ Image envoyée vers Firebase Storage');

      // ----------------------------------------------------------
      // 3. Récupérer l'URL publique/de téléchargement
      // ----------------------------------------------------------

      debugPrint('🔗 Récupération de downloadURL...');

      final String url = await ref.getDownloadURL();

      debugPrint('✅ URL récupérée');
      debugPrint('🔗 URL : $url');

      // ----------------------------------------------------------
      // 4. Enregistrer l'URL dans Firestore
      // ----------------------------------------------------------

      debugPrint(
        '💾 Enregistrement de photoUrl dans Firestore...',
      );

      await firestore
          .collection('users')
          .doc(uid)
          .update({
        'photoUrl': url,
      });

      debugPrint(
        '✅ photoUrl enregistré dans users/$uid',
      );

      debugPrint('🎉 PHOTO DE PROFIL MISE À JOUR');
      debugPrint('==========================================');

      return url;
    } on FirebaseException catch (e) {
      debugPrint('==========================================');
      debugPrint('❌ ERREUR FIREBASE PHOTO');
      debugPrint('Code : ${e.code}');
      debugPrint('Message : ${e.message}');
      debugPrint('==========================================');

      if (e.code == 'unauthorized' ||
          e.code == 'permission-denied') {
        throw Exception(
          'Envoi refusé par Firebase Storage. '
          'Vérifiez les règles de sécurité de Firebase Storage.',
        );
      }

      if (e.code == 'object-not-found') {
        throw Exception(
          'Le fichier n’a pas été trouvé dans Firebase Storage.',
        );
      }

      if (e.code == 'unauthenticated') {
        throw Exception(
          'Utilisateur non authentifié. '
          'Veuillez vous reconnecter.',
        );
      }

      throw Exception(
        'Erreur Firebase lors de l’envoi de la photo : '
        '${e.message ?? e.code}',
      );
    } catch (e) {
      debugPrint('==========================================');
      debugPrint('❌ ERREUR PHOTO');
      debugPrint('Erreur : $e');
      debugPrint('==========================================');

      throw Exception(
        'Impossible d’importer la photo : $e',
      );
    }
  }
}