const express = require('express');
const router = express.Router();
const syncController = require('../controllers/syncController');
const requireApiKey = require('../middlewares/auth');

// Appelée par les Cloud Functions (functions/index.js) à chaque écriture
// Firestore. :resource vaut "universities", "ufrs", "formations" ou
// "academic_levels" (voir server/config/resourceMap.js).
router.post('/:resource', requireApiKey, syncController.syncResource);

module.exports = router;
