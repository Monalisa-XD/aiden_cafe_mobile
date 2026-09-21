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
  const { badge, category, name, description, image, price } = req.body;

  if (!badge || !category || !name || !description || !image) {
    return res.status(400).json({ error: 'Please provide all required fields: badge, category, name, description, and image.' });
  }

  const cleanBadge = String(badge).trim();
  const cleanCategory = String(category).trim();
  const cleanName = String(name).trim();
  const cleanDescription = String(description).trim();
  const cleanImage = String(image).trim();

  if (!cleanBadge || !cleanCategory || !cleanName || !cleanDescription || !cleanImage) {
    return res.status(400).json({ error: 'Fields cannot be empty or whitespace.' });
  }

  if (cleanName.length > 100) {
    return res.status(400).json({ error: 'Menu item name must not exceed 100 characters.' });
  }
  if (cleanCategory.length > 50) {
    return res.status(400).json({ error: 'Category must not exceed 50 characters.' });
  }
  if (cleanBadge.length > 50) {
    return res.status(400).json({ error: 'Badge must not exceed 50 characters.' });
  }
  if (cleanDescription.length > 500) {
    return res.status(400).json({ error: 'Description must not exceed 500 characters.' });
  }

  // Validate image URL format
  if (!cleanImage.startsWith('http://') && !cleanImage.startsWith('https://')) {
    return res.status(400).json({ error: 'Image must be a valid HTTP or HTTPS URL.' });
  }

  // Validate price
  let itemPrice = 50.0;
  if (price !== undefined && price !== null) {
    const parsed = Number(price);
    if (isNaN(parsed) || parsed <= 0 || !isFinite(parsed)) {
      return res.status(400).json({ error: 'Price must be a valid positive number.' });
    }
    itemPrice = Math.round(parsed * 100) / 100;
  }

  const stmt = db.prepare('INSERT INTO menu_items (badge, category, name, description, image, price) VALUES (?, ?, ?, ?, ?, ?)');
  stmt.run(cleanBadge, cleanCategory, cleanName, cleanDescription, cleanImage, itemPrice, function (err) {
    if (err) {
      return res.status(500).json({ error: 'Database error occurred: ' + err.message });
    }
    res.status(201).json({
      message: 'Menu item added successfully!',
      itemId: this.lastID,
      item: {
        id: this.lastID,
        badge: cleanBadge,
        category: cleanCategory,
        name: cleanName,
        description: cleanDescription,
        image: cleanImage,
        price: itemPrice
      }
    });
  });
  stmt.finalize();
};
