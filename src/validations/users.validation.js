import { z } from 'zod';

export const userIdSchema = z.object({
  id: z.string().uuid('Invalid user ID format'),
});

export const updateUserSchema = z.object({
  firstName: z.string().min(1).max(100).optional(),
  lastName: z.string().min(1).max(100).optional(),
  email: z.string().email('Invalid email format').optional(),
  password: z.string().min(8, 'Password must be at least 8 characters').optional(),
  role: z.enum(['user', 'admin', 'moderator']).optional(),
});
