import jwt from 'jsonwebtoken';
import logger from '../config/logger.js';

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '1d';

if (!JWT_SECRET) {
  throw new Error('JWT_SECRET is not defined in environment variables');
}

export const jwttoken = {
  sign: (payload) => {
    try {
      const token = jwt.sign(payload, JWT_SECRET, {
        expiresIn: JWT_EXPIRES_IN,
      });
      return token;
    } catch (error) {
      logger.error('Error signing JWT token:', error);
      throw new Error('Failed to sign JWT token');
    }
  },

  verify: (token) => {
    try {
      const decoded = jwt.verify(token, JWT_SECRET);
      return decoded;
    } catch (error) {
      logger.error('Error verifying JWT token:', error);
      throw new Error('Invalid or expired token');
    }
  },

  decode: (token) => {
    try {
      return jwt.decode(token);
    } catch (error) {
      logger.error('Error decoding JWT token:', error);
      throw new Error('Failed to decode token');
    }
  },
};
