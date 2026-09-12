const pool = require('../config/db');

// Récupération de la liste des universités actives (non supprimées).
exports.getUniversities = async (req, res) => {
  try {
    const [universities] = await pool.query(
      'SELECT * FROM universities WHERE is_deleted = 0 ORDER BY name',
    );
    res.json(universities);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Création ou mise à jour d'une université (INSERT / UPDATE).
exports.saveUniversity = async (req, res) => {
  try {
    const { id, name, city, address, latitude, longitude } = req.body;

    if (!name || !city) {
      return res.status(400).json({ success: false, error: 'Les champs "name" et "city" sont requis.' });
    }

    if (id) {
      // UPDATE
      const query = 'UPDATE universities SET name=?, city=?, address=?, latitude=?, longitude=? WHERE id=?';
      await pool.query(query, [name, city, address, latitude, longitude, id]);
      res.json({ success: true, message: 'Université mise à jour avec succès' });
    } else {
      // INSERT (id généré côté MySQL avec UUID, faute d'auto-incrément ici
      // puisque les autres tables utilisent des id texte type Firestore)
      const newId = require('crypto').randomUUID();
      const query = `INSERT INTO universities (id, name, city, address, latitude, longitude)
        VALUES (?, ?, ?, ?, ?, ?)`;
      await pool.query(query, [newId, name, city, address, latitude, longitude]);
      res.json({ success: true, message: 'Université créée avec succès', id: newId });
    }
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// Suppression logique d'une université (is_deleted = 1), pour rester
// cohérent avec le comportement de l'application Flutter côté Firestore.
exports.deleteUniversity = async (req, res) => {
  try {
    const { id } = req.body;
    if (!id) {
      return res.status(400).json({ success: false, error: 'Le champ "id" est requis.' });
    }
    await pool.query('UPDATE universities SET is_deleted = 1 WHERE id = ?', [id]);
    res.json({ success: true, message: 'Université supprimée avec succès' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};
