import express from 'express';
import { getDb } from '../database/db.js';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

// POST /api/payments/initiate
router.post('/initiate', async (req, res) => {
  try {
    const { userId, documentId, amount, method, phoneNumber } = req.body;
    
    if (!userId || !amount || !method) {
      return res.status(400).json({ error: 'userId, amount et method sont requis' });
    }

    const dbInstance = getDb();
    const id = uuidv4();
    const transactionId = `TXN-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    
    await dbInstance.run(
      'INSERT INTO payments (id, userId, documentId, amount, method, status, transactionId, phoneNumber) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [id, userId, documentId || null, amount, method, 'pending', transactionId, phoneNumber || null]
    );

    const payment = await dbInstance.get('SELECT * FROM payments WHERE id = ?', [id]);
    res.status(201).json(payment);
  } catch (error) {
    console.error('Erreur lors de l\'initiation du paiement:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// POST /api/payments/process
router.post('/process', async (req, res) => {
  try {
    const { paymentId, status } = req.body;
    
    if (!paymentId || !status) {
      return res.status(400).json({ error: 'paymentId et status sont requis' });
    }

    const dbInstance = getDb();
    
    // Vérifier que le paiement existe
    const payment = await dbInstance.get('SELECT * FROM payments WHERE id = ?', [paymentId]);
    if (!payment) {
      return res.status(404).json({ error: 'Paiement non trouvé' });
    }

    // Mettre à jour le statut
    await dbInstance.run(
      'UPDATE payments SET status = ?, updatedAt = datetime("now") WHERE id = ?',
      [status, paymentId]
    );

    // Si le paiement est réussi et qu'il y a un documentId, créer un achat
    if (status === 'completed' && payment.documentId) {
      const purchaseId = uuidv4();
      await dbInstance.run(
        'INSERT INTO user_purchases (id, userId, documentId, paymentId) VALUES (?, ?, ?, ?)',
        [purchaseId, payment.userId, payment.documentId, paymentId]
      );
    }

    const updatedPayment = await dbInstance.get('SELECT * FROM payments WHERE id = ?', [paymentId]);
    res.json(updatedPayment);
  } catch (error) {
    console.error('Erreur lors du traitement du paiement:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/payments/:id
router.get('/:id', async (req, res) => {
  try {
    const dbInstance = getDb();
    const payment = await dbInstance.get('SELECT * FROM payments WHERE id = ?', [req.params.id]);
    
    if (!payment) {
      return res.status(404).json({ error: 'Paiement non trouvé' });
    }
    
    res.json(payment);
  } catch (error) {
    console.error('Erreur lors de la récupération du paiement:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/payments/history/:userId
router.get('/history/:userId', async (req, res) => {
  try {
    const dbInstance = getDb();
    const payments = await dbInstance.all(
      'SELECT * FROM payments WHERE userId = ? ORDER BY createdAt DESC',
      [req.params.userId]
    );
    res.json(payments);
  } catch (error) {
    console.error('Erreur lors de la récupération de l\'historique:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// POST /api/payments/simulate-mobile-money (compatibilité avec document_service.dart)
router.post('/simulate-mobile-money', async (req, res) => {
  try {
    const { userId, documentId, phoneNumber, amount } = req.body;
    
    if (!userId || !documentId || !phoneNumber || !amount) {
      return res.status(400).json({ error: 'userId, documentId, phoneNumber et amount sont requis' });
    }

    const dbInstance = getDb();
    const paymentId = uuidv4();
    const transactionId = `TXN-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    
    // Créer le paiement
    await dbInstance.run(
      'INSERT INTO payments (id, userId, documentId, amount, method, status, transactionId, phoneNumber) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [paymentId, userId, documentId, amount, 'mobile_money', 'completed', transactionId, phoneNumber]
    );

    // Créer l'achat automatiquement
    const purchaseId = uuidv4();
    await dbInstance.run(
      'INSERT INTO user_purchases (id, userId, documentId, paymentId) VALUES (?, ?, ?, ?)',
      [purchaseId, userId, documentId, paymentId]
    );

    const payment = await dbInstance.get('SELECT * FROM payments WHERE id = ?', [paymentId]);
    
    res.json({
      success: true,
      paymentId: payment.id,
      transactionId: payment.transactionId,
      status: payment.status,
      message: 'Paiement simulé avec succès'
    });
  } catch (error) {
    console.error('Erreur lors de la simulation du paiement:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/payments/access/:userId/:documentId (compatibilité avec document_service.dart)
router.get('/access/:userId/:documentId', async (req, res) => {
  try {
    const dbInstance = getDb();
    const purchase = await dbInstance.get(
      'SELECT * FROM user_purchases WHERE userId = ? AND documentId = ?',
      [req.params.userId, req.params.documentId]
    );
    
    if (purchase) {
      res.json({ hasAccess: true });
    } else {
      res.status(404).json({ hasAccess: false });
    }
  } catch (error) {
    console.error('Erreur lors de la vérification de l\'accès:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

export default router;

