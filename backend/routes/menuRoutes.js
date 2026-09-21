import express from 'express';
import { getMenuItems, addMenuItem } from '../controllers/menuController.js';
import { verifyToken, requireRole } from '../middleware/authMiddleware.js';

const router = express.Router();

// Public route to view menu items
router.get('/', getMenuItems);

// Protected route to create new menu items (OWNER or ADMIN only)
router.post('/', verifyToken, requireRole('OWNER', 'ADMIN'), addMenuItem);

export default router;
