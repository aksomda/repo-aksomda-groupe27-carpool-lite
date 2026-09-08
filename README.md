# repo_aksomda_groupe27_carpool_lite - Application de covoiturage des étudiants

Application Flutter de covoiturage des étudiants.
Le projet est organisé selon une approche **Feature-First + Clean Architecture** et
communique avec firebase.

## 1. Fonctionnalités

### Authentification double facteur

- Connexion par email et mot de passe.
- Inscription avec nom, prénom, âge, téléphone, email et mot de passe.
- Stockage sécurisé de l'access token et du refresh token.
- Injection automatique du JWT sur les routes protégées.
- Rafraîchissement automatique du JWT lorsqu'une requête protégée reçoit un `401`.
- Verrouillage des rafraîchissements concurrents : plusieurs requêtes expirées
  partagent le même refresh en cours.
- Suppression des tokens lorsque le refresh échoue ou lors de la déconnexion.

### Écrans métier

1. Tableau de bord.
2. Menu.
3. Commandes.
4. Stocks.
5. Personnel / serveuses.

Les cinq écrans métier consomment des données provenant de l'API et disposent d'une
stratégie de cache pour les lectures.

---

## 2. Architecture

Le projet suit une organisation Feature-First :

````text
lib/
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── router/
│   ├── utils/
│   └── theme/
│
├── features/
│
│   ├── auth/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   ├── universities/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   ├── profile/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   ├── vehicles/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   ├── trips/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   ├── bookings/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   ├── chat/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   ├── notifications/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   ├── reviews/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   └── statistics/
│       ├── presentation/
│       ├── domain/
│       └── data/
│
└── main.dart

Chaque fonctionnalité métier suit autant que possible les trois couches suivantes :

```text
features/<feature>/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── controllers/
    ├── pages/
    └── widgets/
````

### Règles de dépendance

- `domain` ne dépend ni de Dio, ni de Hive, ni de Flutter.
- `data` implémente les contrats du `domain`.
- Les `remote datasource` sont responsables des appels HTTP et du mapping JSON.
- Les `local datasource` sont responsables de la persistance Hive.
- Les repositories orchestrent réseau, cache et traduction des erreurs.
- Les controllers orchestrent l'état de l'interface et ne connaissent pas les détails de

Cette séparation facilite les tests unitaires et limite le couplage entre l'interface,
le réseau et la persistance.
