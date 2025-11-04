import { AdminDataManager, exampleReferenceData } from './admin_data_manager.js';
import { initializeDatabase } from '../database/db.js';

/**
 * Script pour charger les données de référence (à exécuter par l'admin)
 * 
 * Usage:
 *   node admin/load_reference_data.js
 * 
 * NOTE: Ces données doivent être fournies par l'admin, pas générées automatiquement
 */

const loadReferenceData = async () => {
  try {
    console.log('🔄 Initialisation de la base de données...');
    await initializeDatabase();
    
    console.log('📊 Chargement des données de référence...');
    console.log('⚠️  NOTE: Ces données doivent être fournies par l\'admin, pas générées automatiquement');
    console.log('⚠️  Modifiez ce fichier pour charger vos propres données de référence\n');
    
    const results = await AdminDataManager.loadFromJson(exampleReferenceData);
    
    console.log('✅ Données de référence chargées:');
    console.log(`   - ${results.regions.length} régions`);
    console.log(`   - ${results.soilTypes.length} types de sols`);
    console.log(`   - ${results.crops.length} cultures`);
    console.log('\n✅ Chargement terminé!');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur lors du chargement:', error);
    process.exit(1);
  }
};

loadReferenceData();

