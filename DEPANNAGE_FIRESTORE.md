# Dépannage Firestore

Ce document est référencé par les messages d'erreur de l'app (voir
`lib/core/constants/firestore_timeout.dart`, `university_remote_datasource.dart`,
`campus_remote_datasource.dart`). Si vous voyez l'erreur *"Délai dépassé en
contactant Firestore"*, suivez cette checklist dans l'ordre.

## 1. La base Firestore existe-t-elle vraiment ?

Console Firebase → projet **carpoollite** → *Firestore Database*. Si rien
n'apparaît, la base n'a jamais été créée : cliquez sur *Créer une base de
données*, mode **Natif**, choisissez une région proche (ex. `eur3` ou
`nam5`). C'est la cause la plus fréquente d'un timeout qui ne se résout
jamais, même en réessayant.

## 2. Les règles de sécurité sont-elles encore valides ?

Console Firebase → *Firestore Database* → *Règles*. Si le projet a été créé
en mode test, les règles par défaut **expirent automatiquement au bout de
30 jours** — après quoi tous les accès sont bloqués. Ce dépôt contient
désormais des règles définitives dans `firestore.rules` (ouvertes en
lecture/écriture, car l'app n'a pas encore d'authentification). Déployez-les
avec :

```bash
firebase deploy --only firestore:rules
```

## 3. La clé API est-elle correctement restreinte (Android/APK) ?

Google Cloud Console → *Identifiants* → la clé associée à
`android` dans `lib/firebase_options.dart`. Elle doit être restreinte au nom
de package `com.example.repoAksomdaGroupe27CarpoolLite` **et** à
l'empreinte SHA-1 du certificat utilisé pour signer l'APK. Une clé mal
restreinte fonctionne souvent en dev web mais bloque silencieusement
Firestore une fois l'app packagée.

## 4. Le réseau est-il simplement instable au moment du test ?

Une connexion partagée (ex. partage d'écran vidéo en parallèle), une 3G/4G
faible, ou un pare-feu d'établissement peuvent suffire à faire échouer la
connexion temps réel Firestore. L'app réessaie désormais automatiquement
(voir `lib/core/firebase/firestore_retry.dart`) et bascule sur les données
en cache local si la persistance hors-ligne est active — mais un réseau
durablement bloquant Google APIs restera en échec.

## Ce que le code fait déjà pour limiter les dégâts

- `Settings(persistenceEnabled: true)` (dans `main.dart`) : cache local,
  affiché immédiatement pendant une reconnexion.
- `FirestoreRetry` : réessaie automatiquement les lectures/écritures avec un
  délai croissant, et attend le retour du réseau plutôt que d'insister dans
  le vide.

Rien de tout ça ne peut compenser un point 1, 2 ou 3 mal configuré : ces
trois-là se corrigent côté console Firebase / Google Cloud, pas dans le
code Flutter.
