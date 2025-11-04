import express from 'express';
import { getDb } from '../database/db.js';
import { WeatherService } from '../services/weatherService.js';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

// GET /api/weather/current
router.get('/current', async (req, res) => {
  try {
    const { latitude, longitude } = req.query;
    
    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'latitude et longitude sont requis' });
    }

    const lat = parseFloat(latitude);
    const lon = parseFloat(longitude);

    if (isNaN(lat) || isNaN(lon)) {
      return res.status(400).json({ error: 'latitude et longitude doivent être des nombres valides' });
    }

    // Récupérer les données météo réelles depuis OpenWeather
    const weatherData = await WeatherService.getCurrentWeather(lat, lon);
    
    // Ajouter les recommandations agricoles
    weatherData.recommendations = WeatherService.getAgriculturalRecommendations(weatherData);
    weatherData.isFavorableForPlanting = weatherData.temperature >= 20 && 
                                         weatherData.temperature <= 35 && 
                                         weatherData.humidity >= 40 && 
                                         weatherData.humidity <= 80 && 
                                         weatherData.rainfall <= 5;
    weatherData.isFavorableForHarvest = weatherData.rainfall <= 2 && weatherData.windSpeed <= 20;

    res.json(weatherData);
  } catch (error) {
    console.error('Erreur lors de la récupération de la météo:', error);
    
    // Si l'API key n'est pas configurée, retourner une erreur claire
    if (error.message.includes('OPENWEATHER_API_KEY')) {
      return res.status(503).json({ 
        error: 'Service météo non configuré',
        message: 'Veuillez configurer OPENWEATHER_API_KEY dans le fichier .env',
        details: error.message
      });
    }
    
    res.status(500).json({ error: 'Erreur serveur', details: error.message });
  }
});

// GET /api/weather/forecast
router.get('/forecast', async (req, res) => {
  try {
    const { latitude, longitude, days = 5 } = req.query;
    
    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'latitude et longitude sont requis' });
    }

    const lat = parseFloat(latitude);
    const lon = parseFloat(longitude);
    const daysCount = parseInt(days);

    if (isNaN(lat) || isNaN(lon)) {
      return res.status(400).json({ error: 'latitude et longitude doivent être des nombres valides' });
    }

    const forecasts = await WeatherService.getForecast(lat, lon, daysCount);
    res.json(forecasts);
  } catch (error) {
    console.error('Erreur lors de la récupération des prévisions:', error);
    
    if (error.message.includes('OPENWEATHER_API_KEY')) {
      return res.status(503).json({ 
        error: 'Service météo non configuré',
        message: 'Veuillez configurer OPENWEATHER_API_KEY dans le fichier .env',
        details: error.message
      });
    }
    
    res.status(500).json({ error: 'Erreur serveur', details: error.message });
  }
});

// GET /api/weather/alerts
router.get('/alerts', async (req, res) => {
  try {
    const dbInstance = getDb();
    const alerts = await dbInstance.all(
      'SELECT * FROM weather_alerts WHERE endTime > datetime("now") ORDER BY severity DESC, startTime ASC'
    );
    res.json(alerts);
  } catch (error) {
    console.error('Erreur lors de la récupération des alertes:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/weather/alerts/:type
router.get('/alerts/:type', async (req, res) => {
  try {
    const dbInstance = getDb();
    const alerts = await dbInstance.all(
      'SELECT * FROM weather_alerts WHERE type = ? AND endTime > datetime("now") ORDER BY severity DESC',
      [req.params.type]
    );
    res.json(alerts);
  } catch (error) {
    console.error('Erreur lors de la récupération des alertes:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// POST /api/weather/alerts
router.post('/alerts', async (req, res) => {
  try {
    const { location, type, severity, title, description, startTime, endTime, recommendations } = req.body;
    
    if (!location || !type || !severity || !title || !startTime || !endTime) {
      return res.status(400).json({ error: 'Tous les champs requis sont: location, type, severity, title, startTime, endTime' });
    }

    const dbInstance = getDb();
    const id = uuidv4();
    
    await dbInstance.run(
      'INSERT INTO weather_alerts (id, location, type, severity, title, description, startTime, endTime, recommendations) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [id, location, type, severity, title, description || '', startTime, endTime, JSON.stringify(recommendations || [])]
    );

    const alert = await dbInstance.get('SELECT * FROM weather_alerts WHERE id = ?', [id]);
    res.status(201).json(alert);
  } catch (error) {
    console.error('Erreur lors de la création de l\'alerte:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

export default router;

