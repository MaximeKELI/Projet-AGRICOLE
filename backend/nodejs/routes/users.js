import express from 'express';
import { getDb } from '../database/db.js';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

// GET /api/users/:id
router.get('/:id', async (req, res) => {
  try {
    const dbInstance = getDb();
    const user = await dbInstance.get('SELECT * FROM users WHERE id = ?', [req.params.id]);
    
    if (!user) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }
    
    res.json(user);
  } catch (error) {
    console.error('Erreur lors de la récupération de l\'utilisateur:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/users/email/:email
router.get('/email/:email', async (req, res) => {
  try {
    const dbInstance = getDb();
    const user = await dbInstance.get('SELECT * FROM users WHERE email = ?', [req.params.email]);
    
    if (!user) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }
    
    res.json(user);
  } catch (error) {
    console.error('Erreur lors de la récupération de l\'utilisateur:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// POST /api/users
router.post('/', async (req, res) => {
  try {
    const { name, email, phoneNumber } = req.body;
    
    if (!name || !email || !phoneNumber) {
      return res.status(400).json({ error: 'Tous les champs sont requis' });
    }
    
    const dbInstance = getDb();
    
    // Vérifier si l'email existe déjà
    const existingUser = await dbInstance.get('SELECT * FROM users WHERE email = ?', [email]);
    if (existingUser) {
      return res.status(400).json({ error: 'Un utilisateur avec cet email existe déjà' });
    }
    
    const id = uuidv4();
    await dbInstance.run(
      'INSERT INTO users (id, name, email, phoneNumber) VALUES (?, ?, ?, ?)',
      [id, name, email, phoneNumber]
    );
    
    const newUser = await dbInstance.get('SELECT * FROM users WHERE id = ?', [id]);
    res.status(201).json(newUser);
  } catch (error) {
    console.error('Erreur lors de la création de l\'utilisateur:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/users/:userId/purchases
router.get('/:userId/purchases', async (req, res) => {
  try {
    const dbInstance = getDb();
    const purchases = await dbInstance.all(`
      SELECT 
        up.*,
        dr.title as documentTitle,
        dr.category as documentCategory,
        p.status as paymentStatus,
        p.amount,
        p.method as paymentMethod
      FROM user_purchases up
      LEFT JOIN document_recommendations dr ON up.documentId = dr.id
      LEFT JOIN payments p ON up.paymentId = p.id
      WHERE up.userId = ?
      ORDER BY up.purchasedAt DESC
    `, [req.params.userId]);
    
    res.json(purchases);
  } catch (error) {
    console.error('Erreur lors de la récupération des achats:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

export default router;

