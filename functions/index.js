const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { defineString } = require('firebase-functions/params');
const logger = require('firebase-functions/logger');
const axios = require('axios');

// Paramètres configurables sans toucher au code (via functions/.env, ou
// `firebase functions:config` / secrets en production). Voir functions/.env.example.
const SYNC_API_BASE_URL = defineString('SYNC_API_BASE_URL', {
  description: "URL de base de l'API de synchronisation MySQL (ex: https://votre-api.exemple.com/api/sync)",
});
const SYNC_API_KEY = defineString('SYNC_API_KEY', {
  description: "Clé API partagée avec server/.env (SYNC_API_KEY)",
});

/**
 * Envoie l'état courant d'un document Firestore à l'API de synchronisation
 * MySQL. Un même appel gère aussi bien une création qu'une modification —
 * y compris une suppression logique, qui n'est qu'une mise à jour du champ
 * isDeleted côté Firestore.
 */
async function syncToMysql(resource, id, data) {
  const url = `${SYNC_API_BASE_URL.value()}/${resource}`;
  await axios.post(
    url,
    { id, data },
    {
      headers: { 'x-api-key': SYNC_API_KEY.value() },
      timeout: 10000,
    },
  );
}

/**
 * Fabrique un déclencheur Firestore "onWrite" (création + modification, y
 * compris la suppression logique) pour une collection donnée.
 */
function makeSyncTrigger(resource, collectionPath) {
  return onDocumentWritten(collectionPath, async (event) => {
    const afterSnap = event.data?.after;

    // Document supprimé physiquement de Firestore (l'application utilise
    // normalement la suppression logique, mais on gère le cas au cas où) :
    // on ne touche pas à MySQL pour ne pas perdre l'historique.
    if (!afterSnap || !afterSnap.exists) {
      logger.info(`[${resource}] document ${event.params.id} supprimé physiquement, synchronisation ignorée.`);
      return;
    }

    const data = afterSnap.data();

    try {
      await syncToMysql(resource, event.params.id, data);
      logger.info(`[${resource}] document ${event.params.id} synchronisé avec MySQL.`);
    } catch (error) {
      logger.error(`[${resource}] échec de synchronisation pour ${event.params.id} :`, error.message);
      // On relance l'erreur pour que Cloud Functions retente automatiquement.
      throw error;
    }
  });
}

exports.syncUniversities = makeSyncTrigger('universities', 'universities/{id}');
exports.syncCampus = makeSyncTrigger('campus', 'campus/{id}');
exports.syncUfrs = makeSyncTrigger('ufrs', 'ufrs/{id}');
exports.syncFormations = makeSyncTrigger('formations', 'formations/{id}');
exports.syncAcademicLevels = makeSyncTrigger('academic_levels', 'academic_levels/{id}');
