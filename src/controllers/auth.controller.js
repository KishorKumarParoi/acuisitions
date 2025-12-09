import logger from '../config/logger.js';
import { comparePassword, createUser, getUserByEmail } from '../services/auth.service.js';
import { formatValidationErrors } from '../utils/format.js';
import { signUpSchema, signInSchema } from '../validations/auth.validation.js';
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

    // Generate tokens
    const accessToken = jwttoken.sign(
      { id: user.id, email: user.email, role: user.role },
      'access',
    );
    const refreshToken = jwttoken.sign({ id: user.id, email: user.email }, 'refresh');

    // Set tokens in cookies
    cookies.set(res, 'accessToken', accessToken, {
      httpOnly: true,
      secure: true,
      sameSite: 'Strict',
      maxAge: 15 * 60 * 1000, // 15 minutes
    });
    cookies.set(res, 'refreshToken', refreshToken, {
      httpOnly: true,
      secure: true,
      sameSite: 'Strict',
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    });

    logger.info(`User signed up: ${name}, ${email}, ${role || 'user'}`);

    return res.status(201).json({
      message: 'User signed up successfully',
      data: {
        user: {
          id: user.id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          role: user.role,
        },
        accessToken,
        refreshToken,
      },
    });
  } catch (error) {
    logger.error('Error in signup controller:', error);
    if (error.message === 'User already exists') {
      return res.status(409).json({ message: 'Email already exists' });
    }
    return next(error);
  }
};

export const signin = async (req, res, next) => {
  try {
    const validationResult = signInSchema.safeParse(req.body);

    if (!validationResult.success) {
      return res.status(400).json({
        message: 'Validation Failed',
        errors: formatValidationErrors(validationResult.error),
      });
    }

    const { email, password } = validationResult.data;

    const existingUser = await getUserByEmail(email);

    if (!existingUser) {
      logger.warn(`Sign in attempt with non-existent email: ${email}`);
      return res.status(404).json({ message: 'User not found' });
    }

    const isPasswordMatched = await comparePassword(password, existingUser.password);

    if (!isPasswordMatched) {
      logger.warn(`Sign in attempt with wrong password for: ${email}`);
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // if (!existingUser.isActive) {
    //   logger.warn(`Sign in attempt with inactive account: ${email}`);
    //   console.log("Existing User: ", existingUser);
    //   return res.status(403).json({ message: 'Account is inactive' });
    // }

    // Generate tokens
    const accessToken = jwttoken.sign(
      { id: existingUser.id, email: existingUser.email, role: existingUser.role },
      'access',
    );
    const refreshToken = jwttoken.sign(
      { id: existingUser.id, email: existingUser.email },
      'refresh',
    );

    // Set tokens in cookies
    cookies.set(res, 'accessToken', accessToken, {
      httpOnly: true,
      secure: true,
      sameSite: 'Strict',
      maxAge: 15 * 60 * 1000, // 15 minutes
    });
    cookies.set(res, 'refreshToken', refreshToken, {
      httpOnly: true,
      secure: true,
      sameSite: 'Strict',
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    });

    logger.info(`User signed in: ${email}`);

    return res.status(200).json({
      message: 'User signed in successfully',
      data: {
        user: {
          id: existingUser.id,
          firstName: existingUser.firstName,
          lastName: existingUser.lastName,
          email: existingUser.email,
          role: existingUser.role,
        },
        accessToken,
        refreshToken,
      },
    });
  } catch (error) {
    logger.error('Error in signin controller:', error);
    return next(error);
  }
};

export const signout = async (req, res, next) => {
  try {
    cookies.clear(res, 'accessToken', {
      httpOnly: true,
      secure: true,
      sameSite: 'Strict',
    });
    cookies.clear(res, 'refreshToken', {
      httpOnly: true,
      secure: true,
      sameSite: 'Strict',
    });

    logger.info(`User signed out: ${req.user?.email}`);

    return res.status(200).json({
      message: 'User signed out successfully',
    });
  } catch (error) {
    logger.error('Error in signout controller:', error);
    return next(error);
  }
};

export const refreshAccessToken = async (req, res) => {
  try {
    const refreshToken = req.cookies?.refreshToken;

    if (!refreshToken) {
      return res.status(401).json({ message: 'Refresh token not found' });
    }

    const decoded = jwttoken.verify(refreshToken, 'refresh');

    const user = await getUserByEmail(decoded.email);

    if (!user || !user.isActive) {
      return res.status(403).json({ message: 'User not found or inactive' });
    }

    const newAccessToken = jwttoken.sign(
      { id: user.id, email: user.email, role: user.role },
      'access',
    );

    cookies.set(res, 'accessToken', newAccessToken, {
      httpOnly: true,
      secure: true,
      sameSite: 'Strict',
      maxAge: 15 * 60 * 1000,
    });

    logger.info(`Access token refreshed for: ${user.email}`);

    return res.status(200).json({
      message: 'Access token refreshed successfully',
      accessToken: newAccessToken,
    });
  } catch (error) {
    logger.error('Error refreshing access token:', error);
    return res.status(401).json({ message: 'Invalid refresh token' });
  }
};
