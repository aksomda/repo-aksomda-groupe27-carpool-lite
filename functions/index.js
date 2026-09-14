const {
  onDocumentWritten,
  onDocumentCreated,
} = require('firebase-functions/v2/firestore');

const { defineString } = require('firebase-functions/params');

const logger = require('firebase-functions/logger');

const axios = require('axios');

const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// ============================================================
// PARAMÈTRES SYNCHRONISATION MYSQL
// ============================================================

const SYNC_API_BASE_URL = defineString(
  'SYNC_API_BASE_URL',
  {
    description:
      'URL de base de l\'API de synchronisation MySQL',
  },
);

const SYNC_API_KEY = defineString(
  'SYNC_API_KEY',
  {
    description:
      'Clé API partagée avec server/.env',
  },
);

// ============================================================
// SYNCHRONISATION FIRESTORE → MYSQL
// ============================================================

async function syncToMysql(
  resource,
  id,
  data,
) {
  const url =
    `${SYNC_API_BASE_URL.value()}/${resource}`;

  await axios.post(
    url,
    {
      id,
      data,
    },
    {
      headers: {
        'x-api-key':
          SYNC_API_KEY.value(),
      },
      timeout: 10000,
    },
  );
}

// ============================================================
// TRIGGER SYNCHRONISATION
// ============================================================

function makeSyncTrigger(
  resource,
  collectionPath,
) {
  return onDocumentWritten(
    collectionPath,
    async (event) => {
      const afterSnap =
        event.data?.after;

      if (
        !afterSnap ||
        !afterSnap.exists
      ) {
        logger.info(
          `[${resource}] document ${event.params.id} supprimé physiquement, synchronisation ignorée.`,
        );

        return;
      }

      const data =
        afterSnap.data();

      try {
        await syncToMysql(
          resource,
          event.params.id,
          data,
        );

        logger.info(
          `[${resource}] document ${event.params.id} synchronisé avec MySQL.`,
        );
      } catch (error) {
        logger.error(
          `[${resource}] échec de synchronisation pour ${event.params.id}:`,
          error,
        );

        throw error;
      }
    },
  );
}

// ============================================================
// TRIGGERS MYSQL EXISTANTS
// ============================================================

exports.syncUniversities =
  makeSyncTrigger(
    'universities',
    'universities/{id}',
  );

exports.syncCampus =
  makeSyncTrigger(
    'campus',
    'campus/{id}',
  );

exports.syncUfrs =
  makeSyncTrigger(
    'ufrs',
    'ufrs/{id}',
  );

exports.syncFormations =
  makeSyncTrigger(
    'formations',
    'formations/{id}',
  );

exports.syncAcademicLevels =
  makeSyncTrigger(
    'academic_levels',
    'academic_levels/{id}',
  );

// ============================================================
// NOTIFICATION CHAT
// ============================================================

exports.onChatMessageCreated =
  onDocumentCreated(
    'messages/{messageId}',
    async (event) => {
      const snapshot =
        event.data;

      if (!snapshot) {
        logger.error(
          '❌ Snapshot message introuvable',
        );

        return;
      }

      const message =
        snapshot.data();

      const senderId =
        message.senderId;

      const receiverId =
        message.receiverId;

      const text =
        message.text ?? '';

      logger.info(
        '📨 Nouveau message',
        {
          messageId: snapshot.id,
          senderId,
          receiverId,
          text,
        },
      );

      // ========================================================
      // VALIDATION
      // ========================================================

      if (
        !senderId ||
        !receiverId
      ) {
        logger.error(
          '❌ senderId ou receiverId manquant',
        );

        return;
      }

      // ========================================================
      // RÉCUPÉRER LE PROFIL DE L'EXPÉDITEUR
      // ========================================================

      const senderSnapshot =
        await db
          .collection('users')
          .doc(senderId)
          .get();

      const senderData =
        senderSnapshot.data() ?? {};

      const senderName =
        senderData.pseudo ??
        senderData.name ??
        senderData.nom ??
        'CarPool Lite';

      // ========================================================
      // CRÉER LA NOTIFICATION DANS FIRESTORE
      // ========================================================

      await db
        .collection('users')
        .doc(receiverId)
        .collection('notifications')
        .add({
          title: senderName,
          body: text,
          type: 'chat',

          senderId: senderId,
          receiverId: receiverId,

          messageId: snapshot.id,

          conversationId:
            message.conversationId ??
            `${senderId}_${receiverId}`,

          isRead: false,

          createdAt:
            admin.firestore.FieldValue
              .serverTimestamp(),

          data: {
            type: 'chat',
            senderId: senderId,
            receiverId: receiverId,
            messageId: snapshot.id,
          },
        });

      logger.info(
        '✅ Notification Firestore créée',
        {
          receiverId,
        },
      );

      // ========================================================
      // RÉCUPÉRER LES DEVICES DU DESTINATAIRE
      // ========================================================

      const devicesSnapshot =
        await db
          .collection('users')
          .doc(receiverId)
          .collection('devices')
          .get();

      if (
        devicesSnapshot.empty
      ) {
        logger.warn(
          '⚠️ Aucun device enregistré pour le destinataire',
          {
            receiverId,
          },
        );

        return;
      }

      // ========================================================
      // RÉCUPÉRER LES TOKENS
      // ========================================================

      const tokens = [];

      devicesSnapshot.forEach(
        (deviceDoc) => {
          const device =
            deviceDoc.data();

          const token =
            device.fcmToken;

          if (
            token &&
            typeof token === 'string'
          ) {
            tokens.push(token);
          }
        },
      );

      if (tokens.length === 0) {
        logger.warn(
          '⚠️ Aucun token FCM valide',
        );

        return;
      }

      logger.info(
        `📱 ${tokens.length} device(s) trouvé(s)`,
      );

      // ========================================================
      // ENVOYER LA NOTIFICATION
      // ========================================================

      const response =
        await messaging
          .sendEachForMulticast({
            tokens,

            notification: {
              title: senderName,
              body: text,
            },

            data: {
              type: 'chat',
              senderId: String(senderId),
              receiverId: String(receiverId),
              messageId: String(snapshot.id),

              conversationId: String(
                message.conversationId ??
                  `${senderId}_${receiverId}`,
              ),
            },

            android: {
              priority: 'high',

              notification: {
                channelId:
                  'carpool_notifications',

                sound: 'default',
              },
            },
          });

      logger.info(
        '📨 Résultat envoi FCM',
        {
          successCount:
            response.successCount,

          failureCount:
            response.failureCount,
        },
      );

      // ========================================================
      // SUPPRIMER LES TOKENS INVALIDES
      // ========================================================

      for (
        let i = 0;
        i < response.responses.length;
        i++
      ) {
        const result =
          response.responses[i];

        if (!result.success) {
          const errorCode =
            result.error?.code;

          logger.warn(
            '❌ Échec FCM',
            {
              token: tokens[i],
              errorCode,
              error:
                result.error?.message,
            },
          );

          // Token devenu invalide
          if (
            errorCode ===
              'messaging/registration-token-not-registered' ||
            errorCode ===
              'messaging/invalid-registration-token'
          ) {
            logger.info(
              '🗑️ Token FCM invalide détecté',
            );

            // Recherche du document correspondant
            const invalidDeviceSnapshot =
              await db
                .collection('users')
                .doc(receiverId)
                .collection('devices')
                .where(
                  'fcmToken',
                  '==',
                  tokens[i],
                )
                .get();

            for (
              const deviceDoc
                of invalidDeviceSnapshot.docs
            ) {
              await deviceDoc.ref.delete();
            }
          }
        }
      }

      logger.info(
        '🎉 Traitement notification terminé',
      );
    },
  );