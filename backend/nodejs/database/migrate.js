import sqlite3 from 'sqlite3';
import { promisify } from 'util';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import dotenv from 'dotenv';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const DB_PATH = process.env.DB_PATH || path.join(__dirname, '../agriculture.db');

const promisifyDb = (db) => {
  return {
    run: promisify(db.run.bind(db)),
    get: promisify(db.get.bind(db)),
    all: promisify(db.all.bind(db)),
    close: promisify(db.close.bind(db))
  };
};

const migrateDatabase = async () => {
  return new Promise((resolve, reject) => {
    const db = new sqlite3.Database(DB_PATH, (err) => {
      if (err) {
        console.error('❌ Erreur lors de l\'ouverture de la base de données:', err);
        reject(err);
        return;
      }
      console.log('✅ Base de données ouverte');
    });

    const dbPromisified = promisifyDb(db);

    const runMigration = async () => {
      try {
        console.log('🔄 Début de la migration...\n');

        // 1. Migration de la table agricultural_metrics
        console.log('📊 Migration de la table agricultural_metrics...');
        
        // Vérifier quelles colonnes existent déjà
        const tableInfo = await dbPromisified.all(`PRAGMA table_info(agricultural_metrics)`);
        const existingColumns = tableInfo.map(col => col.name);
        
        const columnsToAdd = [
          { name: 'plantedArea', type: 'REAL', exists: existingColumns.includes('plantedArea') },
          { name: 'totalCost', type: 'REAL', exists: existingColumns.includes('totalCost') },
          { name: 'revenue', type: 'REAL', exists: existingColumns.includes('revenue') },
          { name: 'profit', type: 'REAL', exists: existingColumns.includes('profit') },
          { name: 'status', type: 'TEXT DEFAULT "planted"', exists: existingColumns.includes('status') },
          { name: 'weatherData', type: 'TEXT DEFAULT "{}"', exists: existingColumns.includes('weatherData') },
          { name: 'soilData', type: 'TEXT DEFAULT "{}"', exists: existingColumns.includes('soilData') }
        ];

        for (const column of columnsToAdd) {
          if (!column.exists) {
            console.log(`  ➕ Ajout de la colonne ${column.name}...`);
            await dbPromisified.run(
              `ALTER TABLE agricultural_metrics ADD COLUMN ${column.name} ${column.type}`
            );
            console.log(`  ✅ Colonne ${column.name} ajoutée`);
          } else {
            console.log(`  ⏭️  Colonne ${column.name} existe déjà`);
          }
        }

        // Copier area vers plantedArea si plantedArea est NULL et area existe
        const hasArea = existingColumns.includes('area');
        const hasPlantedArea = existingColumns.includes('plantedArea');
        if (hasArea && hasPlantedArea) {
          console.log('  🔄 Copie de area vers plantedArea pour les valeurs NULL...');
          await dbPromisified.run(
            `UPDATE agricultural_metrics SET plantedArea = area WHERE plantedArea IS NULL AND area IS NOT NULL`
          );
        }

        // Calculer costPerHectare si totalCost et area existent
        if (existingColumns.includes('totalCost') && hasArea) {
          console.log('  🔄 Calcul de costPerHectare à partir de totalCost et area...');
          await dbPromisified.run(
            `UPDATE agricultural_metrics 
             SET costPerHectare = CASE 
               WHEN area > 0 THEN totalCost / area 
               ELSE NULL 
             END 
             WHERE costPerHectare IS NULL AND totalCost IS NOT NULL AND area IS NOT NULL AND area > 0`
          );
        }

        console.log('✅ Migration agricultural_metrics terminée\n');

        // 2. Migration de la table document_recommendations
        console.log('📄 Migration de la table document_recommendations...');
        
        const docTableInfo = await dbPromisified.all(`PRAGMA table_info(document_recommendations)`);
        const existingDocColumns = docTableInfo.map(col => col.name);
        
        const docColumnsToAdd = [
          { name: 'fileSizeBytes', type: 'INTEGER DEFAULT 0', exists: existingDocColumns.includes('fileSizeBytes') },
          { name: 'fileExtension', type: 'TEXT DEFAULT "pdf"', exists: existingDocColumns.includes('fileExtension') },
          { name: 'isActive', type: 'INTEGER DEFAULT 1', exists: existingDocColumns.includes('isActive') },
          { name: 'updatedAt', type: 'DATETIME DEFAULT CURRENT_TIMESTAMP', exists: existingDocColumns.includes('updatedAt') }
        ];

        for (const column of docColumnsToAdd) {
          if (!column.exists) {
            console.log(`  ➕ Ajout de la colonne ${column.name}...`);
            await dbPromisified.run(
              `ALTER TABLE document_recommendations ADD COLUMN ${column.name} ${column.type}`
            );
            console.log(`  ✅ Colonne ${column.name} ajoutée`);
          } else {
            console.log(`  ⏭️  Colonne ${column.name} existe déjà`);
          }
        }

        // Mettre à jour updatedAt avec createdAt si updatedAt est NULL
        if (existingDocColumns.includes('updatedAt') && existingDocColumns.includes('createdAt')) {
          console.log('  🔄 Mise à jour de updatedAt avec createdAt...');
          await dbPromisified.run(
            `UPDATE document_recommendations SET updatedAt = createdAt WHERE updatedAt IS NULL`
          );
        }

        console.log('✅ Migration document_recommendations terminée\n');

        console.log('✅ Migration terminée avec succès!');
        resolve();
      } catch (error) {
        console.error('❌ Erreur lors de la migration:', error);
        reject(error);
      } finally {
        await dbPromisified.close();
      }
    };

    runMigration();
  });
};

// Exécuter la migration
migrateDatabase()
  .then(() => {
    console.log('\n🎉 Migration complétée avec succès!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n❌ Erreur lors de la migration:', error);
    process.exit(1);
  });

