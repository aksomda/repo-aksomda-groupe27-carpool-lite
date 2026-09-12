const mysql = require('mysql2/promise');

// Toutes les valeurs viennent de server/.env (voir server/.env.example).
// Ne jamais remettre d'identifiants en dur ici : ce fichier est versionné.
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT ? Number(process.env.DB_PORT) : 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'carpoollite',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

module.exports = pool;
