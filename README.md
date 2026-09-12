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

### Écrans métier Etudiant

1. Tableau de bord.
2. Trajets.
3. Véhicules.
4. Evalution des conducteurs.
5. Personnel / serveuses.

Les cinq écrans métier consomment des données provenant de l'API et disposent d'une
stratégie de cache pour les lectures.


### Écrans métier Administrateur

1. Tableau de bord.
2. Gestion des université.
3. Gestion des campus.
4. Gestion des Ufrs.
5. Gestion des classes.
6. Trajets
7. Véhicules
---

## 2. Architecture

Le projet suit une organisation Feature-First :

```text
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
│  ├── campus/
│  │  ├── presentation/
│  │  ├── domain/
│  │  └── data/
│  │
│  ├── ufrs/
│  │  ├── presentation/
│  │  ├── domain/
│  │  └── data/
│  │
│  ├── formations/
│  │  ├── presentation/
│  │  ├── domain/
│  │  └── data/
│  │
│  ├── levels/
│  │  ├── presentation/
│  │  ├── domain/
│  │  └── data/
│  │
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
```

### Règles de dépendance

- `domain` ne dépend ni de Dio, ni de Hive, ni de Flutter.
- `data` implémente les contrats du `domain`.
- Les `remote datasource` sont responsables des appels HTTP et du mapping JSON.
- Les `local datasource` sont responsables de la persistance Hive.
- Les repositories orchestrent réseau, cache et traduction des erreurs.
- Les controllers orchestrent l'état de l'interface et ne connaissent pas les détails de


Cette séparation facilite les tests unitaires et limite le couplage entre l'interface,
le réseau et la persistance.

---

## 3. API de synchronisation MySQL — endpoints pour tests Postman

En plus de l'application Flutter (qui parle directement à Firestore), le
dossier `server/` expose une API Node.js/Express utilisée par les Cloud
Functions pour répliquer les données dans MySQL (voir
`SYNCHRONISATION_MYSQL.md` pour la mise en place complète). Ces endpoints
sont testables directement avec Postman (ou `curl`) pendant le
développement, sans passer par Firestore.

**URL de base (en local)** : `http://localhost:4000`
(démarrage : `cd server && npm install && npm start`)

### 3.1 Endpoint générique de synchronisation

Utilisé par les Cloud Functions pour les 5 collections. Toutes les requêtes
nécessitent l'en-tête `x-api-key` (valeur définie dans `server/.env`,
`SYNC_API_KEY`).

```
POST /api/sync/:resource
Content-Type: application/json
x-api-key: <SYNC_API_KEY>

{
  "id": "<id du document Firestore>",
  "data": { ...champs du document... }
}
```

`:resource` accepte l'une des 5 valeurs suivantes, avec le corps
correspondant :

**`universities`**
```json
POST http://localhost:4000/api/sync/universities
{
  "id": "uni-1",
  "data": {
    "name": "Université Nazi Boni",
    "city": "Bobo-Dioulasso",
    "address": "01 BP 1091 Bobo-Dioulasso 01",
    "latitude": "11,20926° N",
    "longitude": "-4,41762° O",
    "isDeleted": false
  }
}
```

**`campus`**
```json
POST http://localhost:4000/api/sync/campus
{
  "id": "campus-1",
  "data": {
    "name": "Campus de Nasso",
    "code": "CAMP-NASSO",
    "universityId": "uni-1",
    "universityName": "Université Nazi Boni",
    "isDeleted": false
  }
}
```

**`ufrs`**
```json
POST http://localhost:4000/api/sync/ufrs
{
  "id": "ufr-1",
  "data": {
    "name": "UFR Sciences Exactes et Appliquées",
    "code": "UFR-SEA",
    "campusId": "campus-1",
    "campusName": "Campus de Nasso",
    "isDeleted": false
  }
}
```

**`formations`**
```json
POST http://localhost:4000/api/sync/formations
{
  "id": "formation-1",
  "data": {
    "name": "Licence en Informatique",
    "code": "LIC-INFO",
    "diploma": "Licence",
    "ufrId": "ufr-1",
    "ufrName": "UFR Sciences Exactes et Appliquées",
    "isDeleted": false
  }
}
```

**`academic_levels`**
```json
POST http://localhost:4000/api/sync/academic_levels
{
  "id": "level-1",
  "data": {
    "name": "Licence 1",
    "academicYear": "2025-2026",
    "formationId": "formation-1",
    "formationName": "Licence en Informatique",
    "isDeleted": false
  }
}
```

Pour tester une **suppression logique**, renvoyez le même `id` avec
`"isDeleted": true` dans `data` : la ligne MySQL correspondante passe à
`is_deleted = 1` (upsert, aucune ligne n'est jamais supprimée physiquement).

**Réponses possibles** :
| Code | Cas |
|---|---|
| `200` | Synchronisation réussie |
| `400` | `id` ou `data` manquant dans le corps de la requête |
| `401` | En-tête `x-api-key` manquant ou incorrect |
| `404` | `:resource` inconnu (doit être l'une des 5 valeurs ci-dessus) |
| `500` | Erreur MySQL (connexion, colonne, etc.) |

### 3.2 Endpoints directs (CRUD universités, sans passer par Firestore)

Ne nécessitent pas de `x-api-key`. Utiles pour un outil d'administration qui
lirait/écrirait MySQL sans passer par l'app Flutter.

```
GET  /api/universities
POST /api/universities/save
POST /api/universities/delete
```

**`GET /api/universities`** — liste des universités actives (`is_deleted = 0`).
Pas de corps de requête.

**`POST /api/universities/save`** — création (si `id` absent) ou mise à jour
(si `id` fourni) :
```json
{
  "name": "Université Joseph Ki-Zerbo",
  "city": "Ouagadougou",
  "address": "Avenue de l'Indépendance",
  "latitude": "12,3714° N",
  "longitude": "-1,5197° O"
}
```

**`POST /api/universities/delete`** — suppression logique :
```json
{ "id": "<id renvoyé par /save>" }
```

### 3.3 Collection Postman rapide

Pour tester rapidement sans tout retaper : dans Postman, créez une
requête `POST` par ligne du tableau ci-dessus, avec l'onglet **Body → raw →
JSON**, et pour les endpoints `/api/sync/*`, ajoutez l'en-tête `x-api-key`
dans l'onglet **Headers**. Un `Environment` Postman avec une variable
`{{base_url}}` (= `http://localhost:4000`) et `{{sync_api_key}}` évite de
tout réécrire à chaque requête.
