import logger from '../config/logger.js';
import { jwttoken } from '../utils/jwt.js';
import { getUserById } from '../services/users.service.js';

const authMiddleware = async (req, res, next) => {
  try {
    // Try Authorization header first
    let token = null;
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      token = authHeader.slice(7);
    } else if (req.cookies?.accessToken) {
      token = req.cookies.accessToken;
    }

    if (!token) {
      logger.warn(`Unauthorized access attempt from ${req.ip}`);
      return res.status(401).json({
        message: 'Authentication token is missing',
      });
    }

    // Verify token
    const decoded = jwttoken.verify(token);

    // Fetch user from database
    const user = await getUserById(decoded.id);

    if (!user) {
      logger.warn(`Token belongs to non-existent user: ${decoded.id}`);
      return res.status(401).json({
        message: 'User not found',
      });
    }

    // if (!user.isActive) {
    //   logger.warn(`Inactive user attempted access: ${user.id}`);
    //   return res.status(403).json({
    //     message: 'Your account has been deactivated',
    //   });
    // }

    // Attach user to request
    req.user = {
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
      isActive: user.isActive,
    };

    logger.debug(`User authenticated: ${user.email}`);
    next();
  } catch (error) {
    logger.error('Authentication middleware error:', error);

    if (error.message === 'Invalid or expired token') {
      return res.status(401).json({
        message: 'Invalid or expired token',
      });
    }

    if (error.message === 'User not found') {
      return res.status(404).json({
        message: 'User not found',
      });
    }

    return res.status(401).json({
      message: 'Authentication failed',
    });
  }
};

export default authMiddleware;
