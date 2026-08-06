import db from '../database/db.js';

export const getMenuItems = (req, res) => {
  db.all('SELECT * FROM menu_items', [], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: 'Database error occurred: ' + err.message });
    }
    res.json(rows);
  });
};

export const addMenuItem = (req, res) => {
  const { badge, category, name, description, image } = req.body;

  if (!badge || !category || !name || !description || !image) {
    return res.status(400).json({ error: 'Please provide all required fields.' });
  }

  const stmt = db.prepare('INSERT INTO menu_items (badge, category, name, description, image) VALUES (?, ?, ?, ?, ?)');
  stmt.run(badge, category, name, description, image, function (err) {
    if (err) {
      return res.status(500).json({ error: 'Database error occurred: ' + err.message });
    }
    res.status(201).json({
      message: 'Menu item added successfully!',
      itemId: this.lastID,
      item: { id: this.lastID, badge, category, name, description, image }
    });
  });
  stmt.finalize();
};
