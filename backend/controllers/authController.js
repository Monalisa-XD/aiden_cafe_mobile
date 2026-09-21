import db from '../database/db.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

const getSecretKey = () => process.env.JWT_SECRET || 'insecure-fallback-dev-secret';

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const ALLOWED_ROLES = ['OWNER', 'STAFF', 'CUSTOMER'];

export const register = (req, res) => {
  const { name, email, password, role } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Please provide all required fields: name, email, and password.' });
  }

  const cleanName = String(name).trim();
  const cleanEmail = String(email).trim().toLowerCase();

  if (cleanName.length < 2 || cleanName.length > 100) {
    return res.status(400).json({ error: 'Name must be between 2 and 100 characters.' });
  }

  if (!EMAIL_REGEX.test(cleanEmail) || cleanEmail.length > 255) {
    return res.status(400).json({ error: 'Please provide a valid email address.' });
  }

  if (typeof password !== 'string' || password.length < 6) {
    return res.status(400).json({ error: 'Password must be at least 6 characters long.' });
  }

  const userRole = role ? String(role).trim().toUpperCase() : 'OWNER';
  if (!ALLOWED_ROLES.includes(userRole)) {
    return res.status(400).json({
      error: `Invalid role specified. Allowed roles are: ${ALLOWED_ROLES.join(', ')}.`
    });
  }

  const passwordHash = bcrypt.hashSync(password, 10);

  const stmt = db.prepare('INSERT INTO users (name, email, password_hash, role) VALUES (?, ?, ?, ?)');
  stmt.run(cleanName, cleanEmail, passwordHash, userRole, function (err) {
    if (err) {
      if (err.message.includes('UNIQUE constraint failed') || err.message.includes('Duplicate entry')) {
        return res.status(409).json({ error: 'Email address already registered.' });
      }
      return res.status(500).json({ error: 'Database error occurred: ' + err.message });
    }
    const token = jwt.sign(
      { id: this.lastID, email: cleanEmail, role: userRole },
      getSecretKey(),
      { expiresIn: '7d' }
    );
    res.status(201).json({
      message: 'User registered successfully!',
      userId: this.lastID,
      token,
      user: { id: this.lastID, name: cleanName, email: cleanEmail, role: userRole }
    });
  });
  stmt.finalize();
};

export const login = (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Please provide both email and password.' });
  }

  const cleanEmail = String(email).trim().toLowerCase();

  db.get('SELECT * FROM users WHERE email = ?', [cleanEmail], (err, user) => {
    if (err) {
      return res.status(500).json({ error: 'Database error occurred.' });
    }

    if (!user) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    const isMatch = bcrypt.compareSync(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      getSecretKey(),
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Login successful!',
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role
      }
    });
  });
};
