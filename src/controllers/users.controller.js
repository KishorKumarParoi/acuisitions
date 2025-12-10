import logger from '../config/logger.js';
import { getAllUsers, getUserById, updateUser, deleteUser } from '../services/users.service.js';
import { formatValidationErrors } from '../utils/format.js';
import { userIdSchema, updateUserSchema } from '../validations/users.validation.js';

export const getUsers = async (req, res, next) => {
  try {
    const users = await getAllUsers();
    logger.info('All users retrieved');

    return res.status(200).json({
      message: 'Users retrieved successfully',
      data: users.map(({ password: _, ...user }) => user),
    });
  } catch (error) {
    logger.error('Error in getUsers controller:', error);
    return next(error);
  }
};

export const getUser = async (req, res, next) => {
  try {
    const validationResult = userIdSchema.safeParse(req.params);

    if (!validationResult.success) {
      return res.status(400).json({
        message: 'Validation Failed',
        errors: formatValidationErrors(validationResult.error),
      });
    }

    const { id } = validationResult.data;
    const user = await getUserById(id);

    logger.info(`User retrieved: ${id}`);

    const { password: _, ...userWithoutPassword } = user;
    return res.status(200).json({
      message: 'User retrieved successfully',
      data: userWithoutPassword,
    });
  } catch (error) {
    logger.error('Error in getUser controller:', error);
    if (error.message === 'User not found') {
      return res.status(404).json({
        message: 'User not found',
      });
    }
    return next(error);
  }
};

export const updateUserProfile = async (req, res, next) => {
  try {
    const validationResult = userIdSchema.safeParse(req.params);

    if (!validationResult.success) {
      return res.status(400).json({
        message: 'Validation Failed',
        errors: formatValidationErrors(validationResult.error),
      });
    }

    const bodyValidation = updateUserSchema.safeParse(req.body);

    if (!bodyValidation.success) {
      return res.status(400).json({
        message: 'Validation Failed',
        errors: formatValidationErrors(bodyValidation.error),
      });
    }

    const { id } = validationResult.data;
    console.log('body dta', bodyValidation.data);
    const updates = bodyValidation.data;

    // Check if user is trying to update their own profile or is admin
    if (req.user.id !== id && req.user.role !== 'admin') {
      logger.warn(`Unauthorized update attempt by ${req.user.id} for user ${id}`);
      return res.status(403).json({
        message: 'You can only update your own profile',
      });
    }

    // Only admins can change role
    if (updates.role && req.user.role !== 'admin') {
      logger.warn(`Non-admin ${req.user.id} attempted to change role`);
      return res.status(403).json({
        message: 'Only admins can change user role',
      });
    }

    const updatedUser = await updateUser(id, updates);

    logger.info(`User profile updated: ${id}`);

    return res.status(200).json({
      message: 'User updated successfully',
      data: updatedUser,
    });
  } catch (error) {
    logger.error('Error in updateUserProfile controller:', error);
    if (error.message === 'User not found') {
      return res.status(404).json({
        message: 'User not found',
      });
    }
    return next(error);
  }
};

export const removeUser = async (req, res, next) => {
  try {
    const validationResult = userIdSchema.safeParse(req.params);

    if (!validationResult.success) {
      return res.status(400).json({
        message: 'Validation Failed',
        errors: formatValidationErrors(validationResult.error),
      });
    }

    const { id } = validationResult.data;

    // Check authorization: user can delete own account or admin can delete any
    if (req.user.id !== id && req.user.role !== 'admin') {
      logger.warn(`Unauthorized delete attempt by ${req.user.id} for user ${id}`);
      return res.status(403).json({
        message: 'You can only delete your own account',
      });
    }

    const result = await deleteUser(id);

    logger.info(`User deleted: ${id}`);

    return res.status(200).json({
      message: result.message,
      data: { id },
    });
  } catch (error) {
    logger.error('Error in removeUser controller:', error);
    if (error.message === 'User not found') {
      return res.status(404).json({
        message: 'User not found',
      });
    }
    return next(error);
  }
};
