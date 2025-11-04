import express from 'express';
import { getDb } from '../database/db.js';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

// GET /api/agricultural-metrics/user/:userId
router.get('/user/:userId', async (req, res) => {
  try {
    const dbInstance = getDb();
    const metrics = await dbInstance.all(
      'SELECT * FROM agricultural_metrics WHERE userId = ? ORDER BY createdAt DESC',
      [req.params.userId]
    );
    
    // Convertir les JSON strings en objets pour chaque métrique
    const processedMetrics = metrics.map(metric => {
      if (metric.weatherData && typeof metric.weatherData === 'string') {
        try {
          metric.weatherData = JSON.parse(metric.weatherData);
        } catch (e) {
          metric.weatherData = {};
        }
      }
      if (metric.soilData && typeof metric.soilData === 'string') {
        try {
          metric.soilData = JSON.parse(metric.soilData);
        } catch (e) {
          metric.soilData = {};
        }
      }
      // Utiliser plantedArea si disponible, sinon area
      if (!metric.plantedArea && metric.area) {
        metric.plantedArea = metric.area;
      }
      return metric;
    });
    
    res.json(processedMetrics);
  } catch (error) {
    console.error('Erreur lors de la récupération des métriques:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/agricultural-metrics/:id
router.get('/:id', async (req, res) => {
  try {
    const dbInstance = getDb();
    const metric = await dbInstance.get('SELECT * FROM agricultural_metrics WHERE id = ?', [req.params.id]);
    
    if (!metric) {
      return res.status(404).json({ error: 'Métrique non trouvée' });
    }
    
    res.json(metric);
  } catch (error) {
    console.error('Erreur lors de la récupération de la métrique:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// POST /api/agricultural-metrics
router.post('/', async (req, res) => {
  try {
    const { 
      userId, cropType, region, plantingDate, harvestDate, 
      plantedArea, area, expectedYield, actualYield, 
      totalCost, costPerHectare, revenue, profit, status,
      weatherData, soilData 
    } = req.body;
    
    if (!userId || !cropType) {
      return res.status(400).json({ error: 'userId et cropType sont requis' });
    }

    const dbInstance = getDb();
    const id = uuidv4();
    
    // Utiliser plantedArea ou area selon ce qui est fourni
    const finalArea = plantedArea || area || 0;
    const finalCostPerHectare = costPerHectare || (totalCost && finalArea > 0 ? totalCost / finalArea : null);
    
    // Calculer yieldEfficiency et daysToHarvest
    const yieldEfficiency = expectedYield > 0 && actualYield ? (actualYield / expectedYield) * 100 : 0;
    const daysToHarvest = plantingDate && harvestDate ? 
      Math.floor((new Date(harvestDate) - new Date(plantingDate)) / (1000 * 60 * 60 * 24)) : 0;
    
    await dbInstance.run(
      `INSERT INTO agricultural_metrics 
       (id, userId, cropType, region, plantingDate, harvestDate, plantedArea, area, expectedYield, actualYield, 
        totalCost, costPerHectare, revenue, profit, status, yieldEfficiency, daysToHarvest, weatherData, soilData) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        id, userId, cropType, region || null, plantingDate || null, harvestDate || null,
        finalArea, finalArea, expectedYield || null, actualYield || null,
        totalCost || null, finalCostPerHectare, revenue || null, profit || null,
        status || 'planted', yieldEfficiency, daysToHarvest,
        JSON.stringify(weatherData || {}), JSON.stringify(soilData || {})
      ]
    );

    const metric = await dbInstance.get('SELECT * FROM agricultural_metrics WHERE id = ?', [id]);
    // Convertir les JSON strings en objets
    if (metric) {
      if (metric.weatherData && typeof metric.weatherData === 'string') {
        metric.weatherData = JSON.parse(metric.weatherData);
      }
      if (metric.soilData && typeof metric.soilData === 'string') {
        metric.soilData = JSON.parse(metric.soilData);
      }
    }
    res.status(201).json(metric);
  } catch (error) {
    console.error('Erreur lors de la création de la métrique:', error);
    res.status(500).json({ error: 'Erreur serveur', details: error.message });
  }
});

// PUT /api/agricultural-metrics/:id
router.put('/:id', async (req, res) => {
  try {
    const { cropType, region, plantingDate, harvestDate, area, expectedYield, actualYield, costPerHectare } = req.body;
    
    const dbInstance = getDb();
    
    // Vérifier que la métrique existe
    const existingMetric = await dbInstance.get('SELECT * FROM agricultural_metrics WHERE id = ?', [req.params.id]);
    if (!existingMetric) {
      return res.status(404).json({ error: 'Métrique non trouvée' });
    }

    // Calculer yieldEfficiency et daysToHarvest
    const finalExpectedYield = expectedYield !== undefined ? expectedYield : existingMetric.expectedYield;
    const finalActualYield = actualYield !== undefined ? actualYield : existingMetric.actualYield;
    const yieldEfficiency = finalExpectedYield > 0 && finalActualYield ? (finalActualYield / finalExpectedYield) * 100 : 0;
    
    const finalPlantingDate = plantingDate || existingMetric.plantingDate;
    const finalHarvestDate = harvestDate || existingMetric.harvestDate;
    const daysToHarvest = finalPlantingDate && finalHarvestDate ? 
      Math.floor((new Date(finalHarvestDate) - new Date(finalPlantingDate)) / (1000 * 60 * 60 * 24)) : 
      existingMetric.daysToHarvest;

    await dbInstance.run(
      `UPDATE agricultural_metrics SET 
       cropType = COALESCE(?, cropType),
       region = COALESCE(?, region),
       plantingDate = COALESCE(?, plantingDate),
       harvestDate = COALESCE(?, harvestDate),
       area = COALESCE(?, area),
       expectedYield = COALESCE(?, expectedYield),
       actualYield = COALESCE(?, actualYield),
       costPerHectare = COALESCE(?, costPerHectare),
       yieldEfficiency = ?,
       daysToHarvest = ?,
       updatedAt = datetime("now")
       WHERE id = ?`,
      [cropType, region, plantingDate, harvestDate, area, expectedYield, actualYield, costPerHectare, 
       yieldEfficiency, daysToHarvest, req.params.id]
    );

    const updatedMetric = await dbInstance.get('SELECT * FROM agricultural_metrics WHERE id = ?', [req.params.id]);
    res.json(updatedMetric);
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la métrique:', error);
    res.status(500).json({ error: 'Erreur serveur', details: error.message });
  }
});

// DELETE /api/agricultural-metrics/:id
router.delete('/:id', async (req, res) => {
  try {
    const dbInstance = getDb();
    
    const result = await dbInstance.run('DELETE FROM agricultural_metrics WHERE id = ?', [req.params.id]);
    
    if (result.changes === 0) {
      return res.status(404).json({ error: 'Métrique non trouvée' });
    }
    
    res.status(204).send();
  } catch (error) {
    console.error('Erreur lors de la suppression de la métrique:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

export default router;

