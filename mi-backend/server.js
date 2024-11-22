const express = require('express');
const { Pool } = require('pg'); // Cliente para PostgreSQL
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const PORT = 3000;

// Configuración de conexión a PostgreSQL con la URL proporcionada por Render
const db = new Pool({
  connectionString: 'postgresql://pia_disp_moviles_user:S4NZQkBBOUUR6zbV38Wu3leGI2f1NuHg@dpg-ct02q60gph6c73fu9p40-a/pia_disp_moviles', // URL de conexión completa
  ssl: {
    rejectUnauthorized: false, // Necesario para conectarse a bases de datos externas en Render
  },
});

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Rutas de autenticación
app.post('/auth/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const results = await db.query(
      'SELECT * FROM users WHERE email = $1 AND password = $2',
      [email, password]
    );

    if (results.rows.length > 0) {
      res.status(200).json({ userId: results.rows[0].id });
    } else {
      res.status(401).json({ error: 'Credenciales inválidas' });
    }
  } catch (err) {
    res.status(500).json({ error: 'Error al autenticar al usuario' });
  }
});

// Obtener datos del usuario
app.get('/users/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const results = await db.query('SELECT * FROM users WHERE id = $1', [id]);

    if (results.rows.length > 0) {
      res.status(200).json({
        name: results.rows[0].name,
        email: results.rows[0].email,
      });
    } else {
      res.status(404).json({ error: 'Usuario no encontrado' });
    }
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener los datos del usuario' });
  }
});

// Ruta para registrar usuarios
app.post('/auth/register', async (req, res) => {
  const { email, password, name } = req.body;

  try {
    const emailExists = await db.query('SELECT * FROM users WHERE email = $1', [email]);

    if (emailExists.rows.length > 0) {
      return res.status(400).json({ error: 'El correo electrónico ya está en uso' });
    }

    await db.query(
      'INSERT INTO users (name, email, password) VALUES ($1, $2, $3)',
      [name, email, password]
    );

    res.status(201).json({ message: 'Usuario registrado exitosamente' });
  } catch (err) {
    res.status(500).json({ error: 'Error al registrar al usuario' });
  }
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Servidor corriendo en http://0.0.0.0:${PORT}`);
});