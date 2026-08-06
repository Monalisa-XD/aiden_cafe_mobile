import db from '../database/db.js';
import bcrypt from 'bcryptjs';

export const register = (req, res) => {
  const { name, email, password, role } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Please provide all required fields.' });
  }

  const passwordHash = bcrypt.hashSync(password, 10);
  const userRole = role || 'OWNER';

  const stmt = db.prepare('INSERT INTO users (name, email, password_hash, role) VALUES (?, ?, ?, ?)');
  stmt.run(name, email, passwordHash, userRole, function (err) {
    if (err) {
      if (err.message.includes('UNIQUE constraint failed')) {
        return res.status(400).json({ error: 'Email address already registered.' });
      }
      return res.status(500).json({ error: 'Database error occurred: ' + err.message });
    }
    res.status(201).json({
      message: 'User registered successfully!',
      userId: this.lastID,
      user: { id: this.lastID, name, email, role: userRole }
    });
  });
  stmt.finalize();
};

export const login = (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Please provide email and password.' });
  }

  db.get('SELECT * FROM users WHERE email = ?', [email], (err, user) => {
    if (err) {
      return res.status(500).json({ error: 'Database error occurred.' });
    }

    if (!user) {
      return res.status(400).json({ error: 'Invalid email or password.' });
    }

    const isMatch = bcrypt.compareSync(password, user.password_hash);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid email or password.' });
    }

    res.json({
      message: 'Login successful!',
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role
      }
    });
  });
};
