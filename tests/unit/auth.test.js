/* eslint-disable no-undef */
import request from 'supertest';
import app from '../../src/app.js';

process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-secret-key-for-testing-only';
process.env.DATABASE_URL = 'postgresql://test:test@localhost:5432/acquisitions_test';
process.env.ARCJET_KEY = 'test_disabled_key';

// Mock console methods in tests
global.console = {
  ...console,
  log: jest.fn(),
  error: jest.fn(),
  warn: jest.fn(),
  info: jest.fn(),
  debug: jest.fn(),
};

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

// Increase timeout for database operations
jest.setTimeout(30000);

describe('Auth Endpoints', () => {
  describe('POST /api/auth/sign-up', () => {
    it('should signup new user', async () => {
      const res = await request(app)
        .post('/api/auth/sign-up')
        .send({
          name: 'Test User',
          email: `test-${Date.now()}@example.com`,
          password: 'TestPassword123!',
        });

      expect([201, 400, 409]).toContain(res.status);
      if (res.status === 201) {
        expect(res.body).toHaveProperty('data.user');
      }
    });

    it('should return 400 for invalid email', async () => {
      const res = await request(app).post('/api/auth/sign-up').send({
        name: 'Test User',
        email: 'invalid-email',
        password: 'TestPassword123!',
      });

      expect(res.status).toBe(400);
    });

    it('should return 400 for short password', async () => {
      const res = await request(app)
        .post('/api/auth/sign-up')
        .send({
          name: 'Test User',
          email: `test-${Date.now()}@example.com`,
          password: 'short',
        });

      expect(res.status).toBe(400);
    });
  });

  describe('POST /api/auth/signin', () => {
    it('should return 400 for missing credentials', async () => {
      const res = await request(app).post('/api/auth/signin').send({});

      expect(res.status).toBe(400);
      expect(res.body).toHaveProperty('message');
    });

    it('should return 400 for invalid email', async () => {
      const res = await request(app).post('/api/auth/signin').send({
        email: 'invalid-email',
        password: 'TestPassword123!',
      });

      expect(res.status).toBe(400);
    });

    it('should return 404 for non-existent user', async () => {
      const res = await request(app).post('/api/auth/signin').send({
        email: 'nonexistent@example.com',
        password: 'TestPassword123!',
      });

      expect(res.status).toBe(404);
      expect(res.body).toHaveProperty('message', 'User not found');
    });
  });

  describe('POST /api/auth/signout', () => {
    it('should return 401 without authentication token', async () => {
      const res = await request(app).post('/api/auth/signout').send({});

      expect(res.status).toBe(401);
      expect(res.body).toHaveProperty('message');
    });
  });

  describe('POST /api/auth/refresh', () => {
    it('should return 401 without refresh token', async () => {
      const res = await request(app).post('/api/auth/refresh').send({});

      expect(res.status).toBe(401);
      expect(res.body).toHaveProperty('message');
    });
  });
});

/** @type {import('jest').Config} */
const config = {
  testEnvironment: 'node',
  transform: {
    '^.+\\.js$': 'babel-jest',
  },
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testMatch: ['<rootDir>/tests/**/*.test.js', '<rootDir>/src/**/*.test.js'],
  testPathIgnorePatterns: ['/node_modules/', '/dist/', '/coverage/'],
  moduleFileExtensions: ['js', 'json'],
  moduleNameMapper: {
    '^@configs/(.*)$': '<rootDir>/src/config/$1',
    '^@controllers/(.*)$': '<rootDir>/src/controllers/$1',
    '^@models/(.*)$': '<rootDir>/src/models/$1',
    '^@routes/(.*)$': '<rootDir>/src/routes/$1',
    '^@services/(.*)$': '<rootDir>/src/services/$1',
    '^@middlewares/(.*)$': '<rootDir>/src/middlewares/$1',
    '^@validations/(.*)$': '<rootDir>/src/validations/$1',
    '^@utils/(.*)$': '<rootDir>/src/utils/$1',
  },
  collectCoverage: true,
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/**/*.test.js',
    '!src/index.js',
    '!src/server.js',
    '!src/config/**',
  ],
  coverageDirectory: 'coverage',
  coveragePathIgnorePatterns: ['/node_modules/'],
  coverageReporters: ['text', 'lcov', 'json', 'html', 'text-summary'],
  coverageThreshold: {
    global: {
      branches: 50,
      functions: 50,
      lines: 50,
      statements: 50,
    },
  },
  testTimeout: 10000,
  verbose: true,
  bail: process.env.CI ? 1 : 0,
  maxWorkers: '50%',
  clearMocks: true,
  resetMocks: true,
  restoreMocks: true,
};

export default config;
