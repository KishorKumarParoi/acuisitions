import { Router } from 'express';
import { signup, signin, signout, refreshAccessToken } from '../controllers/auth.controller.js';
import authMiddleware from '../middlewares/auth.middleware.js';

const router = Router();

// Public routes
router.post('/sign-up', signup);
router.post('/signin', signin);
router.post('/refresh', refreshAccessToken);

// Protected routes
router.post('/signout', authMiddleware, signout);

export default router;
