import express from 'express';
import cors from 'cors';
import authRoutes from './routes/authRoutes.js';
import menuRoutes from './routes/menuRoutes.js';
import locationRoutes from './routes/locationRoutes.js';

const app = express();
const PORT = process.env.PORT || 5000;

// Enable CORS for frontend integration
app.use(cors());

// Body parser
app.use(express.json());

// Register API Routes
app.use('/api/auth', authRoutes);
app.use('/api/menu', menuRoutes);
app.use('/api/locations', locationRoutes);

import db from './database/db.js';

// Simple status route
app.get('/status', (req, res) => {
  res.json({ status: 'online', timestamp: new Date() });
});

// Demo Booking route
app.post('/api/demo-bookings', (req, res) => {
  const { name, email, restaurant_name, phone, message } = req.body;
  if (!name || !email || !restaurant_name || !phone) {
    return res.status(400).json({ error: 'Please provide all required fields.' });
  }

  const stmt = db.prepare('INSERT INTO demo_bookings (name, email, restaurant_name, phone, message) VALUES (?, ?, ?, ?, ?)');
  stmt.run(name, email, restaurant_name, phone, message || '', function (err) {
    if (err) {
      return res.status(500).json({ error: 'Database error occurred: ' + err.message });
    }
    res.status(201).json({
      message: 'Demo booking request received successfully!',
      bookingId: this.lastID
    });
  });
  stmt.finalize();
});

// Start Express Server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
