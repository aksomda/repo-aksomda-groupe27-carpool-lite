const pool = require('../config/db');
const resourceMap = require('../config/resourceMap');

// Reçoit { id, data } depuis la Cloud Function déclenchée sur Firestore et
// fait un upsert (INSERT ... ON DUPLICATE KEY UPDATE) dans la table MySQL
// correspondante. Fonctionne aussi bien pour une création, une modification,
// que pour une suppression logique (isDeleted: true, qui n'est qu'une
// modification de plus côté Firestore).
exports.syncResource = async (req, res) => {
  const { resource } = req.params;
  const mapping = resourceMap[resource];

  if (!mapping) {
    return res.status(404).json({ success: false, error: `Ressource inconnue : ${resource}` });
  }

  const { id, data } = req.body;
  if (!id || !data || typeof data !== 'object') {
    return res.status(400).json({
      success: false,
      error: 'Le corps de la requête doit contenir "id" et "data".',
    });
  }

  try {
    const row = mapping.toRow(id, data);
    const columns = Object.keys(row);
    const placeholders = columns.map(() => '?').join(', ');
    const updateClause = columns
      .filter((c) => c !== 'id')
      .map((c) => `${c} = VALUES(${c})`)
      .join(', ');

    const query = `INSERT INTO ${mapping.table} (${columns.join(', ')}) VALUES (${placeholders})
      ON DUPLICATE KEY UPDATE ${updateClause}`;

    await pool.query(query, Object.values(row));

    res.json({ success: true, message: `${resource} (id=${id}) synchronisé avec MySQL.` });
  } catch (error) {
    console.error(`Erreur de synchronisation MySQL pour ${resource}/${id} :`, error);
    res.status(500).json({ success: false, error: error.message });
  }
};
