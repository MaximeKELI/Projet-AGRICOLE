import express from 'express';
import { getDb } from '../database/db.js';

const router = express.Router();

// GET /api/regions
router.get('/', async (req, res) => {
  try {
    const dbInstance = getDb();
    const regions = await dbInstance.all('SELECT * FROM regions ORDER BY name');
    res.json(regions);
  } catch (error) {
    console.error('Erreur lors de la récupération des régions:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/regions/:regionId/prefectures
router.get('/:regionId/prefectures', async (req, res) => {
  try {
    const dbInstance = getDb();
    const prefectures = await dbInstance.all(
      'SELECT * FROM prefectures WHERE regionId = ? ORDER BY name',
      [req.params.regionId]
    );
    res.json(prefectures);
  } catch (error) {
    console.error('Erreur lors de la récupération des préfectures:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/regions/:regionId/communes
router.get('/:regionId/communes', async (req, res) => {
  try {
    const dbInstance = getDb();
    const communes = await dbInstance.all(`
      SELECT c.* 
      FROM communes c
      INNER JOIN prefectures p ON c.prefectureId = p.id
      WHERE p.regionId = ?
      ORDER BY c.name
    `, [req.params.regionId]);
    res.json(communes);
  } catch (error) {
    console.error('Erreur lors de la récupération des communes:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

export default router;

