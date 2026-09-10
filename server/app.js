require('dotenv').config();

const express = require('express');
const cors = require('cors');

const syncRoutes = require('./routes/syncRoutes');
const universityRoutes = require('./routes/universityRoutes');

const app = express();

app.use(cors());
app.use(express.json());

// Utilisée par les Cloud Functions pour répercuter chaque écriture Firestore
// vers MySQL : POST /api/sync/:resource  { id, data }
app.use('/api/sync', syncRoutes);

// CRUD direct optionnel (ex : outil d'administration lisant MySQL).
app.use('/api', universityRoutes);

app.get('/', (req, res) => {
  res.send('Carpool Lite - API de synchronisation MySQL en ligne.');
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`Serveur de synchronisation démarré sur http://localhost:${PORT}`);
});

module.exports = app;
