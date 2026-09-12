// Sécurise l'API de synchronisation : seule la Cloud Function (ou toute
// autre requête connaissant la clé) peut appeler ces routes. Sans cette
// vérification, n'importe qui trouvant l'URL publique de l'API pourrait
// écrire n'importe quoi dans la base MySQL.
module.exports = function requireApiKey(req, res, next) {
  const providedKey = req.header('x-api-key');
  const expectedKey = process.env.SYNC_API_KEY;

  if (!expectedKey) {
    console.error('SYNC_API_KEY manquant côté serveur (fichier .env).');
    return res.status(500).json({ success: false, error: "Clé API serveur non configurée." });
  }

  if (providedKey !== expectedKey) {
    return res.status(401).json({ success: false, error: 'Clé API invalide ou manquante.' });
  }

  next();
};
