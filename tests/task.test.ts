import request from 'supertest';
import { describe, it, expect } from 'vitest';

import app from '../src/app';

describe('Tasks', () => {

  it('should create a task', async () => {

    const response = await request(app)
      .post('/tasks')
      .send({
        title: 'Learn DevOps'
      });

    expect(response.status).toBe(201);

    expect(response.body.title).toBe('Learn DevOps');

  });

  it('should list tasks', async () => {

    const response = await request(app)
      .get('/tasks');

    expect(response.status).toBe(200);

    expect(Array.isArray(response.body)).toBe(true);

  });

});