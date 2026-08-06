import db from '../database/db.js';

export const getLocations = (req, res) => {
  db.all('SELECT * FROM locations', [], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: 'Database error occurred: ' + err.message });
    }
    res.json(rows);
  });
};
