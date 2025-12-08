import z from 'zod';

export const signUpSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.email().max(255).toLowerCase().trim(),
  password: z.string().min(8).max(100),
  role: z.enum(['user', 'admin']).optional(),
});

export const signInSchema = z.object({
  email: z.email().max(255).toLowerCase().trim(),
  password: z.string().min(8).max(100),
});
