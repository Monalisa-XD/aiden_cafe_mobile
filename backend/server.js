import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import authRoutes from './routes/authRoutes.js';
import menuRoutes from './routes/menuRoutes.js';
import locationRoutes from './routes/locationRoutes.js';
import { verifyToken, requireRole } from './middleware/authMiddleware.js';
import db from './database/db.js';

const app = express();
const PORT = process.env.PORT || 5000;

// Configure CORS with restricted origin support
const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',').map((s) => s.trim())
  : ['http://localhost:5000', 'http://localhost:3000', 'http://127.0.0.1:5000'];

app.use(
  cors({
    origin: (origin, callback) => {
      // Allow mobile apps, curl, and server-to-server requests with no origin
      if (!origin) return callback(null, true);
      if (
        allowedOrigins.includes(origin) ||
        allowedOrigins.includes('*') ||
        origin.startsWith('http://localhost:') ||
        origin.startsWith('http://127.0.0.1:')
      ) {
        return callback(null, true);
      }
      return callback(new Error('Blocked by CORS policy: Origin ' + origin + ' not allowed.'));
    },
    credentials: true,
  })
);

// Body parser
app.use(express.json({ limit: '1mb' }));

// Rate Limiters
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // 10 attempts per 15 min
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many authentication attempts from this IP. Please try again after 15 minutes.' },
});

const submissionLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20, // max 20 submissions per 15 min
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests submitted from this IP. Please try again later.' },
});

// Apply rate limiters to sensitive endpoints
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);

// Register API Routes
app.use('/api/auth', authRoutes);
app.use('/api/menu', menuRoutes);
app.use('/api/locations', locationRoutes);

// Simple status route
app.get('/status', (req, res) => {
  res.json({ status: 'online', timestamp: new Date() });
});

// Validation regex
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const PHONE_REGEX = /^[+0-9\s\-()]{7,25}$/;

// Booking / Enquiry handler
const handleBookingOrEnquiry = (type) => (req, res) => {
  const { name, email, restaurant_name, restaurantName, phone, message } = req.body;
  const targetRestaurant = (restaurant_name || restaurantName || '').trim();

  if (!name || !email || !targetRestaurant || !phone) {
    return res.status(400).json({ error: 'Please provide all required fields: name, email, restaurant/event name, and phone.' });
  }

  const cleanName = String(name).trim();
  const cleanEmail = String(email).trim().toLowerCase();
  const cleanPhone = String(phone).trim();
  const cleanMessage = String(message || '').trim();

  if (cleanName.length < 2 || cleanName.length > 100) {
    return res.status(400).json({ error: 'Name must be between 2 and 100 characters.' });
  }
  if (!EMAIL_REGEX.test(cleanEmail) || cleanEmail.length > 255) {
    return res.status(400).json({ error: 'Please provide a valid email address.' });
  }
  if (!PHONE_REGEX.test(cleanPhone)) {
    return res.status(400).json({ error: 'Please provide a valid contact phone number.' });
  }
  if (targetRestaurant.length > 100) {
    return res.status(400).json({ error: 'Establishment/event name must not exceed 100 characters.' });
  }
  if (cleanMessage.length > 1000) {
    return res.status(400).json({ error: 'Message must not exceed 1000 characters.' });
  }

  const stmt = db.prepare(
    'INSERT INTO demo_bookings (name, email, restaurant_name, phone, message, type) VALUES (?, ?, ?, ?, ?, ?)'
  );
  stmt.run(cleanName, cleanEmail, targetRestaurant, cleanPhone, cleanMessage, type, function (err) {
    if (err) {
      return res.status(500).json({ error: 'Database error occurred: ' + err.message });
    }
    res.status(201).json({
      message: 'Request received successfully! Our team will contact you shortly.',
      bookingId: this.lastID,
      type,
    });
  });
  stmt.finalize();
};

// Public submission routes with rate limiting
app.post('/api/demo-bookings', submissionLimiter, handleBookingOrEnquiry('DEMO'));
app.post('/api/enquiries', submissionLimiter, handleBookingOrEnquiry('ENQUIRY'));

// Protected retrieval routes (OWNER or ADMIN role required)
app.get('/api/demo-bookings', verifyToken, requireRole('OWNER', 'ADMIN'), (req, res) => {
  db.all("SELECT * FROM demo_bookings WHERE type = 'DEMO' ORDER BY created_at DESC", [], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: 'Database error occurred: ' + err.message });
    }
    res.json(rows);
  });
});

app.get('/api/enquiries', verifyToken, requireRole('OWNER', 'ADMIN'), (req, res) => {
  db.all("SELECT * FROM demo_bookings WHERE type = 'ENQUIRY' ORDER BY created_at DESC", [], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: 'Database error occurred: ' + err.message });
    }
    res.json(rows);
  });
});

// 404 handler for undefined routes (returns JSON instead of HTML)
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found: ' + req.method + ' ' + req.originalUrl });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled server error:', err.message);
  res.status(err.status || 500).json({ error: err.message || 'Internal server error occurred.' });
});

// Start Express Server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
