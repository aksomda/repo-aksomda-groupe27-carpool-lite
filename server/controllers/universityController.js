const pool = require('../config/db');

//Récupération de la liste des universités enregistrées
exports.getUniversities = async (requestAnimationFrame, res) => {
    try {
        const [universities] = await pool.query('select * from university');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}

//Création ou mise à jour d'une université (INSERT / UPDATE)
exports.saveUniversity = async (req, res) => {
    try {
        if (id) {
            // UPDATE
            const query = `UPDATE university SET name=?, city=?, address=? WHERE id=?`;
            await pool.query(query, [name, city, address, id]);
            res.json({ success: true, message: 'Université mise à jour avec succès' });
        } else {
            // INSERT
            const maintenant = new Date();

            const created_at = maintenant.getFullYear() + '-' +
                String(maintenant.getMonth() + 1).padStart(2, '0') + '-' +
                String(maintenant.getDate()).padStart(2, '0') + ' ' +
                String(maintenant.getHours()).padStart(2, '0') + ':' +
                String(maintenant.getMinutes()).padStart(2, '0') + ':' +
                String(maintenant.getSeconds()).padStart(2, '0');
            const updated_at = maintenant.getFullYear() + '-' +
                String(maintenant.getMonth() + 1).padStart(2, '0') + '-' +
                String(maintenant.getDate()).padStart(2, '0') + ' ' +
                String(maintenant.getHours()).padStart(2, '0') + ':' +
                String(maintenant.getMinutes()).padStart(2, '0') + ':' +
                String(maintenant.getSeconds()).padStart(2, '0');
            console.log(created_at);
            const query = `INSERT INTO university (name, city, latitude, logitude, address, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)`;
            await pool.query(query, [name, city, latitude, logitude, address, created_at, updated_at]);
            res.json({ success: true, message: 'Université créée avec succès' });
        }
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }

}

// Supprimer une université (DELETE)
exports.deleteUniversity = async (req, res) => {
    try {
        const { id } = req.body;
        await pool.query('DELETE FROM universities WHERE id = ?', [id]);
        res.json({ success: true, message: 'Université supprimée avec succès' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};