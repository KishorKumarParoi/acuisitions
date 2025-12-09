import { Router } from 'express';
import {
  getUsers,
  getUser,
  updateUserProfile,
  removeUser,
} from '../controllers/users.controller.js';
import authMiddleware from '../middlewares/auth.middleware.js';

const router = Router();

// Get all users
router.get('/', authMiddleware, getUsers);

// Get user by ID
router.get('/:id', authMiddleware, getUser);

// Update user
router.put('/:id', authMiddleware, updateUserProfile);

// Delete user
router.delete('/:id', authMiddleware, removeUser);

export default router;
