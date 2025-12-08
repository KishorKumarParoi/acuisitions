import logger from '../config/logger.js';
import { createUser } from '../services/auth.service.js';
import { formatValidationErrors } from '../utils/format.js';
import { signUpSchema } from '../validations/auth.validation.js';
import { jwttoken } from '../utils/jwt.js';
import { cookies } from '../utils/cookies.js';

export const signup = async (req, res, next) => {
  try {
    const validationResult = signUpSchema.safeParse(req.body);

    if (!validationResult.success) {
      return res.status(400).json({
        message: 'Validation Failed',
        errors: formatValidationErrors(validationResult.error),
      });
    }

    const { name, email, role } = validationResult.data;

    const user = await createUser(validationResult.data);
    const token = jwttoken.sign({ id: user.id, email: user.email, role: user.role });
    cookies.set(res, 'token', token, { httpOnly: true, secure: true, sameSite: 'Strict' });

    logger.info(`User signed up: ${name}, ${email}, ${role || 'user'}`);

    return res.status(201).json({
      message: 'User signed up successfully',
      user: { id: user.id, name: user.name, email: user.email, role: user.role },
    });
  } catch (error) {
    logger.error('Error in signup controller:', error);
    if (error.message === 'User already exists') {
      return res.status(409).json({ message: 'Email already exists' });
    }
    return next(error);
  }
};
