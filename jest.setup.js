import dotenv from 'dotenv';
import jest from 'jest-mock';
import global from 'global';

// Load test environment variables
dotenv.config({ path: '.env.test' });

// Mock Arcjet to prevent rate limiting in tests
jest.mock('@arcjet/node', () => ({
  __esModule: true,
  default: () => ({
    protect: jest.fn().mockResolvedValue({
      isDenied: jest.fn().mockReturnValue(false),
      reason: {
        isRateLimit: jest.fn().mockReturnValue(false),
        isBot: jest.fn().mockReturnValue(false),
      },
    }),
    withRule: jest.fn().mockReturnThis(),
  }),
}));

// Set test environment
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-secret-key-for-testing-only';
process.env.DATABASE_URL = 'postgresql://test:test@localhost:5432/acquisitions_test';
process.env.ARCJET_KEY = 'test_arcjet_key';

// Mock console methods in tests
global.console = {
  ...console,
  log: jest.fn(),
  error: jest.fn(),
  warn: jest.fn(),
  info: jest.fn(),
  debug: jest.fn(),
};

// Increase timeout for database operations
jest.setTimeout(30000);
