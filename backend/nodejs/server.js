import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import bodyParser from 'body-parser';
import { initializeDatabase } from './database/db.js';
import usersRoutes from './routes/users.js';
import cropsRoutes from './routes/crops.js';
import regionsRoutes from './routes/regions.js';
import weatherRoutes from './routes/weather.js';
import paymentsRoutes from './routes/payments.js';
import documentsRoutes from './routes/documents.js';
import metricsRoutes from './routes/metrics.js';

// Charger les variables d'environnement
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  credentials: true
}));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.use('/api/users', usersRoutes);
app.use('/api/crops', cropsRoutes);
app.use('/api/regions', regionsRoutes);
app.use('/api/weather', weatherRoutes);
app.use('/api/payments', paymentsRoutes);
app.use('/api/documents', documentsRoutes);
app.use('/api/agricultural-metrics', metricsRoutes);

// Route de santé
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'AGRICOLE API is running' });
});

// Route racine
app.get('/', (req, res) => {
  res.json({ 
    message: 'AGRICOLE API',
    version: '1.0.0',
    endpoints: {
      users: '/api/users',
      crops: '/api/crops',
      regions: '/api/regions',
      weather: '/api/weather',
      payments: '/api/payments',
      documents: '/api/documents',
      metrics: '/api/agricultural-metrics'
    }
  });
});

// Initialiser la base de données et démarrer le serveur
initializeDatabase()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`🚀 Serveur AGRICOLE démarré sur le port ${PORT}`);
      console.log(`📡 API disponible sur http://localhost:${PORT}`);
      console.log(`🔍 Health check: http://localhost:${PORT}/health`);
    });
  })
  .catch((error) => {
    console.error('❌ Erreur lors de l\'initialisation:', error);
    process.exit(1);
  });

export default app;

