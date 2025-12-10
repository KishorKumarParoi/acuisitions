/* eslint-disable no-undef */
import request from 'supertest';
import app from '../app.js';

describe('Users Endpoints', () => {
  describe('GET /api/users', () => {
    it('should return 401 without authentication', async () => {
      const res = await request(app).get('/api/users').expect(401);

      expect(res.body).toHaveProperty('message');
    });
  });

  describe('GET /api/users/:id', () => {
    it('should return 401 without authentication', async () => {
      const res = await request(app).get('/api/users/invalid-id').expect(401);

      expect(res.body).toHaveProperty('message');
    });
  });

  describe('PUT /api/users/:id', () => {
    it('should return 401 without authentication', async () => {
      const res = await request(app)
        .put('/api/users/invalid-id')
        .send({ firstName: 'Updated' })
        .expect(401);

      expect(res.body).toHaveProperty('message');
    });
  });

  describe('DELETE /api/users/:id', () => {
    it('should return 401 without authentication', async () => {
      const res = await request(app).delete('/api/users/invalid-id').expect(401);

      expect(res.body).toHaveProperty('message');
    });
  });
});
