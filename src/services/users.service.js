import logger from '../config/logger.js';
import { db } from '../config/database.js';
import { users } from '../models/user.models.js';
import { eq } from 'drizzle-orm';
import bcrypt from 'bcryptjs';

export const getAllUsers = async () => {
  try {
    const allUsers = await db.select().from(users);
    logger.info(`Retrieved ${allUsers.length} users`);
    return allUsers;
  } catch (error) {
    logger.error('Error fetching all users:', error);
    throw new Error('Failed to fetch users');
  }
};

export const getUserById = async (id) => {
  try {
    const [user] = await db.select().from(users).where(eq(users.id, id)).limit(1);

    if (!user) {
      throw new Error('User not found');
    }

    logger.info(`Retrieved user: ${id}`);
    return user;
  } catch (error) {
    logger.error(`Error fetching user ${id}:`, error);
    throw error;
  }
};

export const updateUser = async (id, updates) => {
  try {
    // Check if user exists
    const [existingUser] = await db.select().from(users).where(eq(users.id, id)).limit(1);

    if (!existingUser) {
      throw new Error('User not found');
    }

    // Hash password if provided
    let updateData = { ...updates };
    if (updates.password) {
      updateData.password = await bcrypt.hash(updates.password, 10);
    }

    // Always update the updatedAt timestamp
    updateData.updatedAt = new Date();

    const [updatedUser] = await db
      .update(users)
      .set(updateData)
      .where(eq(users.id, id))
      .returning();

    logger.info(`User updated: ${id}`);

    // Return user without password
    const { password: _, ...userWithoutPassword } = updatedUser;
    return userWithoutPassword;
  } catch (error) {
    logger.error(`Error updating user ${id}:`, error);
    throw error;
  }
};

export const deleteUser = async (id) => {
  try {
    // Check if user exists
    const [existingUser] = await db.select().from(users).where(eq(users.id, id)).limit(1);

    if (!existingUser) {
      throw new Error('User not found');
    }

    await db.delete(users).where(eq(users.id, id));

    logger.info(`User deleted: ${id}`);
    return { message: 'User deleted successfully', id };
  } catch (error) {
    logger.error(`Error deleting user ${id}:`, error);
    throw error;
  }
};
