import express from 'express';
import { getDb } from '../database/db.js';

const router = express.Router();

// GET /api/crops
router.get('/', async (req, res) => {
  try {
    const dbInstance = getDb();
    const crops = await dbInstance.all('SELECT * FROM crops');
    res.json(crops);
  } catch (error) {
    console.error('Erreur lors de la récupération des cultures:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/crops/:cropId
router.get('/:cropId', async (req, res) => {
  try {
    const dbInstance = getDb();
    const crop = await dbInstance.get('SELECT * FROM crops WHERE id = ?', [req.params.cropId]);
    
    if (!crop) {
      return res.status(404).json({ error: 'Culture non trouvée' });
    }
    
    res.json(crop);
  } catch (error) {
    console.error('Erreur lors de la récupération de la culture:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/crops/recommended/:soilTypeId
router.get('/recommended/:soilTypeId', async (req, res) => {
  try {
    const dbInstance = getDb();
    const crops = await dbInstance.all(`
      SELECT c.*, stc.suitability
      FROM crops c
      INNER JOIN soil_type_crops stc ON c.id = stc.cropId
      WHERE stc.soilTypeId = ?
      ORDER BY stc.suitability DESC
    `, [req.params.soilTypeId]);
    
    res.json(crops);
  } catch (error) {
    console.error('Erreur lors de la récupération des cultures recommandées:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/crops/:cropId/activities/upcoming
router.get('/:cropId/activities/upcoming', async (req, res) => {
  try {
    const { plantingDate } = req.query;
    
    if (!plantingDate) {
      return res.status(400).json({ error: 'plantingDate est requis' });
    }
    
    const dbInstance = getDb();
    const activities = await dbInstance.all(
      'SELECT * FROM crop_activities WHERE cropId = ? ORDER BY days_after_planting ASC',
      [req.params.cropId]
    );
    
    // Filtrer les activités à venir basées sur la date de plantation
    const plantingDateObj = new Date(plantingDate);
    const upcomingActivities = activities.map(activity => ({
      ...activity,
      scheduledDate: new Date(plantingDateObj.getTime() + activity.days_after_planting * 24 * 60 * 60 * 1000)
    })).filter(activity => activity.scheduledDate >= new Date());
    
    res.json(upcomingActivities);
  } catch (error) {
    console.error('Erreur lors de la récupération des activités:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

export default router;

