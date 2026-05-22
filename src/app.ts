import express from 'express';
import cors from 'cors';
import pinoHttp from 'pino-http';

import taskRoutes from './routes/task.routes';
import logger from './config/logger';

const app = express();

app.use(pinoHttp({
  logger
}));

app.use(cors());
app.use(express.json());

app.get('/health', (_, res) => {
  res.json({
    status: 'ok'
  });
});

app.use('/tasks', taskRoutes);

export default app;