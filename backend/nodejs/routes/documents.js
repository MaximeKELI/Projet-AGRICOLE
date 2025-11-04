import express from 'express';
import { getDb } from '../database/db.js';

const router = express.Router();

// GET /api/documents
router.get('/', async (req, res) => {
  try {
    const dbInstance = getDb();
    const documents = await dbInstance.all('SELECT * FROM document_recommendations ORDER BY createdAt DESC');
    
    // S'assurer que tous les champs attendus par Flutter sont présents
    const processedDocuments = documents.map(doc => ({
      ...doc,
      fileSizeBytes: doc.fileSizeBytes || 0,
      fileExtension: doc.fileExtension || 'pdf',
      isActive: doc.isActive !== undefined ? doc.isActive : 1,
      updatedAt: doc.updatedAt || doc.createdAt
    }));
    
    res.json(processedDocuments);
  } catch (error) {
    console.error('Erreur lors de la récupération des documents:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/documents/:id
router.get('/:id', async (req, res) => {
  try {
    const dbInstance = getDb();
    const document = await dbInstance.get('SELECT * FROM document_recommendations WHERE id = ?', [req.params.id]);
    
    if (!document) {
      return res.status(404).json({ error: 'Document non trouvé' });
    }
    
    res.json(document);
  } catch (error) {
    console.error('Erreur lors de la récupération du document:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/documents/category/:category
router.get('/category/:category', async (req, res) => {
  try {
    const dbInstance = getDb();
    const documents = await dbInstance.all(
      'SELECT * FROM document_recommendations WHERE category = ? ORDER BY createdAt DESC',
      [req.params.category]
    );
    
    // S'assurer que tous les champs attendus par Flutter sont présents
    const processedDocuments = documents.map(doc => ({
      ...doc,
      fileSizeBytes: doc.fileSizeBytes || 0,
      fileExtension: doc.fileExtension || 'pdf',
      isActive: doc.isActive !== undefined ? doc.isActive : 1,
      updatedAt: doc.updatedAt || doc.createdAt
    }));
    
    res.json(processedDocuments);
  } catch (error) {
    console.error('Erreur lors de la récupération des documents:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/documents/region/:region
router.get('/region/:region', async (req, res) => {
  try {
    const dbInstance = getDb();
    const documents = await dbInstance.all(
      'SELECT * FROM document_recommendations WHERE region = ? ORDER BY createdAt DESC',
      [req.params.region]
    );
    
    // S'assurer que tous les champs attendus par Flutter sont présents
    const processedDocuments = documents.map(doc => ({
      ...doc,
      fileSizeBytes: doc.fileSizeBytes || 0,
      fileExtension: doc.fileExtension || 'pdf',
      isActive: doc.isActive !== undefined ? doc.isActive : 1,
      updatedAt: doc.updatedAt || doc.createdAt
    }));
    
    res.json(processedDocuments);
  } catch (error) {
    console.error('Erreur lors de la récupération des documents:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/documents/prefecture/:prefecture
router.get('/prefecture/:prefecture', async (req, res) => {
  try {
    const dbInstance = getDb();
    const documents = await dbInstance.all(
      'SELECT * FROM document_recommendations WHERE prefecture = ? ORDER BY createdAt DESC',
      [req.params.prefecture]
    );
    
    // S'assurer que tous les champs attendus par Flutter sont présents
    const processedDocuments = documents.map(doc => ({
      ...doc,
      fileSizeBytes: doc.fileSizeBytes || 0,
      fileExtension: doc.fileExtension || 'pdf',
      isActive: doc.isActive !== undefined ? doc.isActive : 1,
      updatedAt: doc.updatedAt || doc.createdAt
    }));
    
    res.json(processedDocuments);
  } catch (error) {
    console.error('Erreur lors de la récupération des documents:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/documents/:id/download (compatibilité avec document_service.dart)
router.get('/:id/download', async (req, res) => {
  try {
    const { userId } = req.query;
    const dbInstance = getDb();
    
    // Vérifier l'accès
    if (userId) {
      const purchase = await dbInstance.get(
        'SELECT * FROM user_purchases WHERE userId = ? AND documentId = ?',
        [userId, req.params.id]
      );
      
      if (!purchase) {
        // Vérifier si le document est gratuit
        const document = await dbInstance.get('SELECT * FROM document_recommendations WHERE id = ?', [req.params.id]);
        if (!document || document.price > 0) {
          return res.status(403).json({ error: 'Accès non autorisé. Achetez le document d\'abord.' });
        }
      }
    }
    
    const document = await dbInstance.get('SELECT * FROM document_recommendations WHERE id = ?', [req.params.id]);
    
    if (!document) {
      return res.status(404).json({ error: 'Document non trouvé' });
    }
    
    // Pour l'instant, retourner un message indiquant que le fichier n'est pas encore implémenté
    // Dans un vrai système, vous serviriez le fichier depuis le système de fichiers ou un stockage cloud
    res.json({ 
      message: 'Téléchargement non implémenté',
      documentId: document.id,
      filePath: document.filePath
    });
  } catch (error) {
    console.error('Erreur lors du téléchargement:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

export default router;

