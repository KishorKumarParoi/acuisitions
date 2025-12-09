import express from 'express';
import { refreshAccessToken, signin, signout, signup } from '../controllers/auth.controller.js';

const router = express.Router();

router.post('/sign-up', signup);

router.post('/sign-in', signin);

router.post('/sign-out', signout);

router.post('/refresh-token', refreshAccessToken);

export default router;
