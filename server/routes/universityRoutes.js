const express = require('express');
const router = express.Router();
const universityController = require('../controllers/universityController');

router.get('/universities', universityController.getUniversities);
router.post('/universities/save', universityController.saveUniversity);
router.post('/universities/delete', universityController.deleteUniversity);

exports.universityRoutes = router;