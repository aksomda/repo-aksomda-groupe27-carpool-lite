const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: 'localhost',
  user: 'carpoollite',
  password: 'O!oLhp7U[rdp-e./', // Ton mot de passe MySQL
  database: 'carpoollite',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

module.exports = pool;