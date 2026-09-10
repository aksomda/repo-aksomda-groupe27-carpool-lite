# Synchronisation Firestore → MySQL

Cette fonctionnalité est composée de **deux briques séparées** :

```
Application Flutter
        │  écrit dans
        ▼
   Firestore (carpoollite)
        │  déclenche (onDocumentWritten)
        ▼
  functions/  (Cloud Function Firebase)
        │  appelle en HTTPS (POST + clé API)
        ▼
  server/    (API Node.js/Express)
        │  écrit dans
        ▼
   Base MySQL (carpoollite)
```

Collections synchronisées : `universities`, `ufrs`, `formations`,
`academic_levels`. Une suppression dans l'app est **logique**
(`isDeleted: true`) : c'est une simple mise à jour Firestore, donc elle
déclenche la même synchronisation et met `is_deleted = 1` côté MySQL (la
ligne n'est jamais supprimée physiquement).

## 1. Préparer la base MySQL

```bash
mysql -u root -p < server/sql/schema.sql
```

Cela crée la base `carpoollite` et les 4 tables. Créez ensuite un
utilisateur MySQL dédié si ce n'est pas déjà fait, et notez ses identifiants.

## 2. Configurer et lancer l'API (`server/`)

```bash
cd server
npm install
cp .env.example .env
# Éditez .env : identifiants MySQL + une clé secrète SYNC_API_KEY de votre choix
npm start
```

⚠️ **Important** : une Cloud Function tourne sur les serveurs de Google, pas
sur votre machine. Pour qu'elle puisse joindre cette API, celle-ci doit être
accessible publiquement (hébergement sur une VM, Render, Railway, Cloud Run,
etc.) — `localhost` ne fonctionnera que si vous testez tout en local avec
l'émulateur Firebase (étape 4).

## 3. Configurer et déployer les Cloud Functions (`functions/`)

```bash
cd functions
npm install
cp .env.example .env
# Éditez .env : SYNC_API_BASE_URL (l'URL publique de votre API) et la
# MÊME SYNC_API_KEY que dans server/.env
cd ..
firebase login              # avec a.ksomda@gmail.com
firebase use carpoollite    # sélectionne votre projet
firebase deploy --only functions
```

⚠️ **Plan Firebase requis** : les Cloud Functions qui appellent une API
externe (ce qui est le cas ici) nécessitent le plan **Blaze** (paiement à
l'usage) sur votre projet Firebase. Le plan gratuit "Spark" ne suffit pas
pour les appels réseau sortants. Le plan Blaze inclut un quota gratuit
généreux, vous ne serez facturé qu'en cas de très gros volume.

## 4. Tester en local avant de déployer (recommandé)

```bash
cd functions
npm run serve   # démarre l'émulateur Cloud Functions
```

Dans ce mode, `SYNC_API_BASE_URL` peut pointer vers
`http://localhost:4000/api/sync` (l'API `server/` tournant sur votre
machine). Ajoutez ou modifiez une université dans l'app pour vérifier dans
les logs de l'émulateur et de `server/` que la synchronisation se déclenche,
puis vérifiez la table MySQL correspondante.

## Sécurité

- `server/.env` et `functions/.env` ne sont **jamais** commités (voir
  `.gitignore`) : ils contiennent des mots de passe et des clés.
- La clé `SYNC_API_KEY` doit être identique des deux côtés et rester secrète :
  c'est elle qui empêche n'importe qui de pousser des données arbitraires
  dans votre base MySQL en devinant l'URL de l'API.
- ⚠️ Le mot de passe MySQL qui était en dur dans `server/config/db.js`
  a été retiré du code (remplacé par une variable d'environnement). Comme il
  a déjà été présent dans un fichier versionné, **changez ce mot de passe**
  sur votre serveur MySQL par précaution.
