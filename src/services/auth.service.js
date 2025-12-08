import logger from '../config/logger.js';
import bcrypt from 'bcryptjs';
import { users } from '../models/user.models.js';
import { db } from '../config/database.js';
import { eq } from 'drizzle-orm';

export const hashPassword = async (password) => {
  try {
    return await bcrypt.hash(password, 10);
  } catch (error) {
    logger.error('Error hashing password:', error);
    throw new Error('Password hashing failed');
  }
};

export const createUser = async ({ name, email, password, role = 'user' }) => {
  try {
    // Check if user already exists
    const existingUser = await db.select().from(users).where(eq(users.email, email)).limit(1);

    if (existingUser.length > 0) {
      throw new Error('User already exists');
    }

    const hashedPassword = await hashPassword(password);
    const first_name = name.split(' ')[0];
    const last_name = name.split(' ').slice(1).join(' ');

    const [newUser] = await db
      .insert(users)
      .values({
        firstName: first_name,
        lastName: last_name,
        email: email,
        password: hashedPassword,
        role,
      })
      .returning({
        id: users.id,
        firstName: users.firstName,
        lastName: users.lastName,
        email: users.email,
        role: users.role,
      });

    logger.info(`New user created: ${email}`);
    return newUser;
  } catch (error) {
    logger.error('Error creating user:', error);
    throw error;
  }
};

export const comparePassword = async (password, hashedPassword) => {
  try {
    return await bcrypt.compare(password, hashedPassword);
  } catch (error) {
    logger.error('Error comparing passwords:', error);
    throw new Error('Password comparison failed');
  }
};

export const getUserByEmail = async (email) => {
  try {
    const [user] = await db.select().from(users).where(eq(users.email, email)).limit(1);

    return user || null;
  } catch (error) {
    logger.error('Error fetching user by email:', error);
    throw error;
  }
};
