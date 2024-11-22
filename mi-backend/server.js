const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const PORT = 3000;

// Configuración de conexión a MySQL
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',  // Usuario de MySQL
  password: 'InterColor',  // Contraseña actualizada de MySQL
  database: 'InterColor',  // El nombre de tu base de datos
});

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Rutas de autenticación
app.post('/auth/login', (req, res) => {
  const { email, password } = req.body;

  // Buscar el usuario en la base de datos
  db.query(
    'SELECT * FROM users WHERE email = ? AND password = ?',
    [email, password],
    (err, results) => {
      if (err) {
        res.status(500).json({ error: 'Error al autenticar al usuario' });
      } else if (results.length > 0) {
        // Usuario autenticado
        res.status(200).json({ userId: results[0].id });
      } else {
        res.status(401).json({ error: 'Credenciales inválidas' });
      }
    }
  );
});

// Obtener datos del usuario
app.get('/users/:id', (req, res) => {
  const { id } = req.params;

  // Obtener datos del usuario desde la base de datos
  db.query('SELECT * FROM users WHERE id = ?', [id], (err, results) => {
    if (err) {
      res.status(500).json({ error: 'Error al obtener los datos del usuario' });
    } else if (results.length > 0) {
      res.status(200).json({ name: results[0].name, email: results[0].email });
    } else {
      res.status(404).json({ error: 'Usuario no encontrado' });
    }
  });
});

// Ruta para registrar usuarios
app.post('/auth/register', (req, res) => {
  const { email, password, name } = req.body;

  // Verificar si el correo ya existe
  db.query('SELECT * FROM users WHERE email = ?', [email], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Error al verificar el correo' });
    }

    if (results.length > 0) {
      // Si el correo ya está en uso
      return res.status(400).json({ error: 'El correo electrónico ya está en uso' });
    }

    // Si el correo no está registrado, insertamos el nuevo usuario
    db.query(
      'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
      [name, email, password],
      (err, results) => {
        if (err) {
          return res.status(500).json({ error: 'Error al registrar al usuario' });
        }
        // Usuario registrado exitosamente
        res.status(201).json({ message: 'Usuario registrado exitosamente' });
      }
    );
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});