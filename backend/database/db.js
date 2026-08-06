import sqlite3 from 'sqlite3';
import mysql from 'mysql2';
import path from 'path';
import { fileURLToPath } from 'url';
import bcrypt from 'bcryptjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const isMySQL = !!(process.env.MYSQL_HOST || process.env.MYSQL_URL || process.env.DATABASE_URL?.startsWith('mysql:'));

let dbInstance = null;
let useMySQL = false;

if (isMySQL) {
  console.log('Database Configuration: Using MySQL in Production.');
  useMySQL = true;
  
  const config = process.env.MYSQL_URL || process.env.DATABASE_URL || {
    host: process.env.MYSQL_HOST || 'localhost',
    user: process.env.MYSQL_USER || 'root',
    password: process.env.MYSQL_PASSWORD || '',
    database: process.env.MYSQL_DATABASE || 'aiden_cafe',
    port: parseInt(process.env.MYSQL_PORT || '3306'),
    ssl: process.env.MYSQL_SSL === 'true' ? { rejectUnauthorized: false } : undefined
  };

  dbInstance = mysql.createPool(config);
} else {
  console.log('Database Configuration: Using local SQLite database.');
  const dbPath = path.resolve(__dirname, 'database.sqlite');
  dbInstance = new sqlite3.Database(dbPath);
}

// Helper database interface wrapping both SQLite and MySQL calls to follow SQLite's callback pattern
const db = {
  get: (sql, params, callback) => {
    if (useMySQL) {
      dbInstance.execute(sql, params, (err, results) => {
        if (err) return callback(err);
        callback(null, results[0] || null);
      });
    } else {
      dbInstance.get(sql, params, callback);
    }
  },

  all: (sql, params, callback) => {
    if (useMySQL) {
      dbInstance.execute(sql, params, (err, results) => {
        if (err) return callback(err);
        callback(null, results);
      });
    } else {
      dbInstance.all(sql, params, callback);
    }
  },

  run: (sql, params, callback) => {
    if (useMySQL) {
      dbInstance.execute(sql, params, function (err, result) {
        if (err) return callback(err);
        const context = {
          lastID: result.insertId,
          changes: result.affectedRows
        };
        callback.call(context, null);
      });
    } else {
      dbInstance.run(sql, params, callback);
    }
  },

  prepare: (sql) => {
    if (useMySQL) {
      // Mock prepared statement for MySQL
      return {
        run: function (...args) {
          const callback = args[args.length - 1];
          const params = args.slice(0, args.length - 1);
          dbInstance.execute(sql, params, function (err, result) {
            if (err) return callback(err);
            const context = {
              lastID: result.insertId,
              changes: result.affectedRows
            };
            callback.call(context, null);
          });
        },
        finalize: () => {}
      };
    } else {
      return dbInstance.prepare(sql);
    }
  },

  serialize: (callback) => {
    if (useMySQL) {
      callback();
    } else {
      dbInstance.serialize(callback);
    }
  }
};

// Initialize database schema
db.serialize(() => {
  const usersTableSql = useMySQL
    ? `
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        role VARCHAR(50) NOT NULL DEFAULT 'OWNER'
      )
    `
    : `
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'OWNER'
      )
    `;

  const menuTableSql = useMySQL
    ? `
      CREATE TABLE IF NOT EXISTS menu_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        badge VARCHAR(255) NOT NULL,
        category VARCHAR(255) NOT NULL,
        name VARCHAR(255) NOT NULL,
        description TEXT NOT NULL,
        image VARCHAR(255) NOT NULL
      )
    `
    : `
      CREATE TABLE IF NOT EXISTS menu_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        badge TEXT NOT NULL,
        category TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        image TEXT NOT NULL
      )
    `;



  const locationsTableSql = useMySQL
    ? `
      CREATE TABLE IF NOT EXISTS locations (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        address TEXT NOT NULL,
        image VARCHAR(255) NOT NULL
      )
    `
    : `
      CREATE TABLE IF NOT EXISTS locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        image TEXT NOT NULL
      )
    `;

  const demoBookingsTableSql = useMySQL
    ? `
      CREATE TABLE IF NOT EXISTS demo_bookings (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL,
        restaurant_name VARCHAR(255) NOT NULL,
        phone VARCHAR(50) NOT NULL,
        message TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `
    : `
      CREATE TABLE IF NOT EXISTS demo_bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        restaurant_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        message TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `;

  // Run schema creation
  db.run(usersTableSql, [], (err) => {
    if (err) console.error('Error creating users table:', err.message);
  });
  db.run(menuTableSql, [], (err) => {
    if (err) console.error('Error creating menu_items table:', err.message);
  });
  db.run(locationsTableSql, [], (err) => {
    if (err) console.error('Error creating locations table:', err.message);
  });
  db.run(demoBookingsTableSql, [], (err) => {
    if (err) console.error('Error creating demo_bookings table:', err.message);
  });

  // Seed default data if empty
  // 1. Seed Users
  db.get('SELECT COUNT(*) as count FROM users', [], (err, row) => {
    if (err) return console.error(err.message);
    // SQLite returns row.count, MySQL row is a RowDataPacket which also exposes count
    const count = row ? (row.count !== undefined ? row.count : row['COUNT(*)'] || 0) : 0;
    if (count === 0) {
      const defaultUsers = [
        {
          name: 'Maitre D',
          email: 'maitred@aidencafe.com',
          password: 'password123',
          role: 'MANAGER'
        },
        {
          name: 'Sanjay Prabhakar',
          email: 'sanjay@aidencafe.com',
          password: 'password123',
          role: 'OWNER'
        }
      ];

      const stmt = db.prepare('INSERT INTO users (name, email, password_hash, role) VALUES (?, ?, ?, ?)');
      defaultUsers.forEach((user) => {
        const hash = bcrypt.hashSync(user.password, 10);
        stmt.run(user.name, user.email, hash, user.role, (err) => {
          if (err) console.error('Error seeding user:', err.message);
        });
      });
      stmt.finalize();
      console.log('Seeded default users.');
    }
  });

  // 2. Seed Menu Items
  db.get('SELECT COUNT(*) as count FROM menu_items', [], (err, row) => {
    if (err) return console.error(err.message);
    const count = row ? (row.count !== undefined ? row.count : row['COUNT(*)'] || 0) : 0;
    if (count === 0) {
      const menuItems = [
        {
          badge: 'MENU ITEM',
          category: 'SOUTH INDIAN BREAKFAST',
          name: 'Idli',
          description: 'Fluffy steamed rice cakes served with sambar and fresh coconut chutney.',
          image: 'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?auto=format&fit=crop&w=800&q=80'
        },
        {
          badge: 'MENU ITEM',
          category: 'SOUTH INDIAN BREAKFAST',
          name: 'Masala Dosa',
          description: 'Crispy rice crepes filled with spiced potato mash, served with rich chutneys.',
          image: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=800&q=80'
        },
        {
          badge: 'BEVERAGES',
          category: 'AUTHENTIC BREW',
          name: 'Filter Coffee',
          description: 'Freshly brewed decoction mixed with hot frothed milk, served in a traditional dabara.',
          image: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=800&q=80'
        },
        {
          badge: 'MENU ITEM',
          category: 'SOUTH INDIAN BREAKFAST',
          name: 'Medu Vada',
          description: 'Crispy golden fried lentil donuts seasoned with pepper, curry leaves, and cumin.',
          image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80'
        }
      ];

      const stmt = db.prepare('INSERT INTO menu_items (badge, category, name, description, image) VALUES (?, ?, ?, ?, ?)');
      menuItems.forEach((item) => {
        stmt.run(item.badge, item.category, item.name, item.description, item.image, (err) => {
          if (err) console.error('Error seeding menu item:', err.message);
        });
      });
      stmt.finalize();
      console.log('Seeded default menu items.');
    }
  });

  // 3. Seed Locations
  db.get('SELECT COUNT(*) as count FROM locations', [], (err, row) => {
    if (err) return console.error(err.message);
    const count = row ? (row.count !== undefined ? row.count : row['COUNT(*)'] || 0) : 0;
    if (count === 0) {
      const locations = [
        {
          name: 'Basvanagudi',
          address: 'South Kitchen, 1st Main Road, Thyagaraja Nagar, N.R Colony, Bengaluru West City Corporation, Bengaluru, Bangalore North, Bengaluru Urban, Karnataka, 560004, India',
          image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80'
        },
        {
          name: 'Jayanagar',
          address: 'South Kitchen, 4th Block, Near Jayanagar Metro Station, Jayanagar, Bengaluru, Karnataka, 560011, India',
          image: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=800&q=80'
        },
        {
          name: 'Indiranagar',
          address: 'South Kitchen, 100 Feet Road, HAL 2nd Stage, Indiranagar, Bengaluru, Karnataka, 560038, India',
          image: 'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?auto=format&fit=crop&w=800&q=80'
        },
        {
          name: 'Malleshwaram',
          address: 'South Kitchen, Margosa Road, Near 15th Cross, Malleshwaram, Bengaluru, Karnataka, 560003, India',
          image: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=800&q=80'
        }
      ];

      const stmt = db.prepare('INSERT INTO locations (name, address, image) VALUES (?, ?, ?)');
      locations.forEach((loc) => {
        stmt.run(loc.name, loc.address, loc.image, (err) => {
          if (err) console.error('Error seeding location:', err.message);
        });
      });
      stmt.finalize();
      console.log('Seeded default locations.');
    }
  });
});

export default db;
