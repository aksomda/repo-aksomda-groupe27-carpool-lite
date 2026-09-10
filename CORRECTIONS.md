# Corrections appliquées (page blanche + fonctionnalités demandées)

Ce fichier résume les modifications apportées par rapport au dépôt original.
`DEPANNAGE_FIRESTORE.md` reste utile pour le point 1/2 de sa checklist mais
référence des fichiers (`firestore_retry.dart`, `firestore_timeout.dart`,
`campus_remote_datasource.dart`) qui n'ont jamais existé dans ce dépôt : à
ignorer/supprimer.

## 1. Cause racine de la page blanche

1. **Projets Firebase incohérents** : `lib/firebase_options.dart` référence
   le projet `carpool-lite` (appId `1:408768248556:...`), alors que
   `.firebaserc`/`firebase.json` pointent vers `carpoollite`
   (appId `1:254475674559:...`), le projet réellement créé par
   a.ksomda@gmail.com. **Action requise (à faire par vous, accès Firebase
   nécessaire)** :
   ```bash
   flutter pub global activate flutterfire_cli
   firebase login                      # avec a.ksomda@gmail.com
   flutterfire configure --project=carpoollite
   ```
2. `main.dart` appelait `Firebase.initializeApp()` sans lui passer
   `options: DefaultFirebaseOptions.currentPlatform`, et aucun
   `google-services.json`/`GoogleService-Info.plist` n'est présent →
   l'appel levait une exception **avant** `runApp()` → écran blanc. Corrigé
   (options passées + `runZonedGuarded` + écran d'erreur lisible en cas
   d'échec réseau/config).

## 2. Bugs de compilation latents corrigés

Masqués jusqu'ici car `app_router.dart` n'affichait que des `Text()`
statiques, sans jamais importer les vrais écrans.

- `AuthRepository` / `AuthRepositoryImpl` / `SignUpUserCase` ne
  transmettaient pas `phone`/`sex` à `AuthRemoteDataSource.signUp`
  (paramètres requis) → signatures alignées sur les 4 couches.
- `lib/features/universities/domain/usecases/add_univerity_usecase.dart`
  (faute de frappe) renommé en `add_university_usecase.dart` pour
  correspondre à l'import utilisé dans `university_provider.dart`.
- `university_selection_screen.dart` utilisait `context.watch<...>()`
  (package `provider`) sans que ce package soit ni déclaré dans
  `pubspec.yaml`, ni importé dans le fichier → ajouté.
- Dossier dupliqué et vide `lib/features/universities/presentation/data/`
  supprimé (stubs `// TODO Implement this library.` non utilisés).

## 3. Routage câblé sur les vrais écrans

`lib/core/di/injector.dart` (nouveau) construit une fois les
datasources → repositories → usecases → providers (Firebase Auth /
Firestore déjà initialisés dans `main.dart`). `app_router.dart` utilise
maintenant `LoginScreen`, `RegisterScreen`, `VerifyStudentScreen`,
`EmailOtpScreen` et `UniversitySelectionScreen` au lieu de texte statique.

## 4. Écran de démarrage (splash)

- `assets/splash/splash_screen.png` ajouté et déclaré dans `pubspec.yaml`.
- Package `flutter_native_splash` ajouté + configuré.
- **À exécuter après `flutter pub get`** :
  ```bash
  dart run flutter_native_splash:create
  ```
  (régénère les ressources natives Android/iOS ; à relancer si l'image
  change).

## 5. Code de vérification à 08 chiffres par email

Ajouté dans `AuthRemoteDataSource` : `sendEmailOtp` / `verifyEmailOtp`,
propagés jusqu'à `AuthProvider` et exposés via le nouvel écran
`EmailOtpScreen` (route `/auth/verify-email`).

- Le code (8 chiffres, `Random.secure()`) et son expiration (10 min) sont
  stockés dans Firestore, collection `otp_codes/{uid}`.
- L'envoi réel du mail est délégué à un document déposé dans la collection
  `mail`, au format attendu par l'extension officielle Firebase
  **"Trigger Email" (firestore-send-email)** — Firebase Auth seul ne sait
  pas envoyer un code numérique arbitraire par email.
- **À faire côté console Firebase (projet carpoollite, plan Blaze requis)** :
  installer l'extension `firestore-send-email`, la configurer avec un
  fournisseur SMTP (ex. SendGrid, un compte Gmail applicatif, etc.), et la
  pointer vers la collection `mail`.
- ⚠️ **Limite de sécurité connue** : `verifyEmailOtp` compare le code via
  une lecture Firestore côté client. Les règles (`firestore.rules`)
  limitent cette lecture au propriétaire du document, mais cela signifie
  qu'un utilisateur connecté pourrait théoriquement lire son propre code
  sans consulter sa boîte mail. Pour une vérification robuste en
  production, migrer la comparaison vers une Cloud Function (Admin SDK,
  qui ignore les règles Firestore) plutôt qu'une lecture cliente.

## 6. Autres corrections

- `android/app/src/main/AndroidManifest.xml` : ajout de la permission
  `INTERNET` (absente du manifeste release, seulement présente en
  debug/profile).
- `android/settings.gradle.kts` : déclaration (non appliquée) du plugin
  `com.google.gms.google-services`, à activer dans
  `android/app/build.gradle.kts` une fois `google-services.json` déposé.
- `firestore.rules` : passage d'un mode "tout ouvert" à des règles
  minimales par utilisateur connecté (`users`, `otp_codes`, `mail`,
  lecture publique de `universities`).
- `.gitignore` : ajout des logs de crash Gradle (`hs_err_pid*.log`,
  `replay_pid*.log`, plusieurs Mo, sans rapport avec le bug — supprimés du
  dépôt) et des fichiers de config Firebase natifs
  (`google-services.json`, `GoogleService-Info.plist`).

## 7. Ce qui n'a PAS été touché

La majorité des modules (`trips`, `bookings`, `chat`, `favorites`,
`profile`, `reviews`, `statistics`, `vehicles`, `notifications`) sont
encore des fichiers squelettes (`// TODO ...`, une seule ligne) : ce n'est
pas un bug, juste du développement restant, hors périmètre de cette
correction.

## Correction compilation Flutter / Chrome — menus Étudiant & Administrateur

Corrections apportées dans cette version :

1. `publish_trip_screen.dart` : correction de la chaîne contenant l'apostrophe de `d'un`, qui provoquait `Expected ',' before this`.
2. Ajout de `lib/core/widgets/app_drawer.dart`, utilisé par les pages d'administration.
3. Ajout de `lib/core/widgets/confirm_delete_dialog.dart` avec `confirmSoftDelete()`.
4. Ajout de `lib/core/utils/coordinate_parser.dart` avec `parseCoordinate()`.
5. Ajout de la dépendance `google_maps_flutter: ^2.18.0` pour `UniversityDetailPage`.
6. Ajout d'une redirection GoRouter : les routes `/admin/...` sont réservées aux utilisateurs dont le rôle est `admin`.

Après remplacement du projet :

```bash
flutter clean
flutter pub get
flutter analyze
flutter run -d chrome
```

Google Maps sur le Web nécessite également une clé/API Google Maps configurée pour le projet Web lorsque la page de détail d'une université est ouverte.
