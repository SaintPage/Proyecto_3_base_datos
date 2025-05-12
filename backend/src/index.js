const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const app = express();

app.use(cors({ origin: process.env.CORS_ORIGIN }));
app.use(express.json());

// Ejemplo de endpoint GET /api/usuarios
app.get('/api/usuarios', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM "Usuario"');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

const port = process.env.PORT || 3001;
app.listen(port, () => {
  console.log(`Servidor Express escuchando en puerto ${port}`);
});
