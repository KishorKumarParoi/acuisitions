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

export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1),
});

export const logoutSchema = z.object({
  refreshToken: z.string().min(1),
});

// Helper function to format Zod validation errors
export const formatValidationErrors = (error) => {
  return error.errors.map((err) => ({
    field: err.path.join('.'),
    message: err.message,
  }));
};

