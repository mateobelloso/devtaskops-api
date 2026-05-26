import express from 'express';
import cors from 'cors';
import pinoHttp from 'pino-http';

import taskRoutes from './routes/task.routes';
import logger from './config/logger';

import  register, { httpRequestDuration } from './config/metrics';


const app = express();

app.use(pinoHttp({
  logger
}));

app.use(cors());
app.use(express.json());

/**
 * MÉTRICAS PRIMERO (ANTES DE ROUTES)
 */
app.use((req, res, next) => {
  if (req.path === '/metrics') return next();

  const end = httpRequestDuration.startTimer();

  res.on('finish', () => {
    end({
      method: req.method,
      route: req.baseUrl + req.path,
      status_code: res.statusCode,
    });
  });

  next();
});

app.get('/metrics', async (_, res) => {

  res.set('Content-Type', register.contentType);

  res.end(await register.metrics());

});


app.get('/health', (_, res) => {
  res.json({
    status: 'ok'
  });
});


app.use('/tasks', taskRoutes);

export default app;