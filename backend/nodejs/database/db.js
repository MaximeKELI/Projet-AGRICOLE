import sqlite3 from 'sqlite3';
import { promisify } from 'util';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const DB_PATH = process.env.DB_PATH || path.join(__dirname, '../agriculture.db');

let db = null;

// Créer une promesse pour les opérations de base de données
const promisifyDb = (db) => {
  return {
    run: promisify(db.run.bind(db)),
    get: promisify(db.get.bind(db)),
    all: promisify(db.all.bind(db)),
    close: promisify(db.close.bind(db))
  };
};

export const getDb = () => {
  if (!db) {
    throw new Error('Database not initialized. Call initializeDatabase() first.');
  }
  return promisifyDb(db);
};

export const initializeDatabase = async () => {
  return new Promise((resolve, reject) => {
    db = new sqlite3.Database(DB_PATH, (err) => {
      if (err) {
        console.error('❌ Erreur lors de l\'ouverture de la base de données:', err);
        reject(err);
        return;
      }
      console.log('✅ Base de données SQLite connectée');
      
      // Créer les tables
      createTables()
        .then(() => {
          console.log('✅ Tables créées avec succès');
          resolve();
        })
        .catch(reject);
    });
  });
};

const createTables = async () => {
  if (!db) {
    throw new Error('Database not initialized');
  }
  const dbPromisified = promisifyDb(db);
  
  // Table Users
  await dbPromisified.run(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      phoneNumber TEXT NOT NULL,
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Table Regions
  await dbPromisified.run(`
    CREATE TABLE IF NOT EXISTS regions (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      description TEXT
    )
  `);

  // Table Prefectures
  await dbPromisified.run(`
    CREATE TABLE IF NOT EXISTS prefectures (
      id TEXT PRIMARY KEY,
      regionId TEXT NOT NULL,
      name TEXT NOT NULL,
      description TEXT,
      FOREIGN KEY (regionId) REFERENCES regions(id)
    )
  `);

  // Table Communes
  await dbPromisified.run(`
    CREATE TABLE IF NOT EXISTS communes (
      id TEXT PRIMARY KEY,
      prefectureId TEXT NOT NULL,
      name TEXT NOT NULL,
      latitude REAL,
      longitude REAL,
      FOREIGN KEY (prefectureId) REFERENCES prefectures(id)
    )
  `);

  // Table SoilTypes
  await dbPromisified.run(`
    CREATE TABLE IF NOT EXISTS soil_types (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      description TEXT,
      ph_min REAL,
      ph_max REAL,
      organic_matter REAL,
      texture TEXT
    )
  `);

  // Table Crops
  await dbPromisified.run(`
    CREATE TABLE IF NOT EXISTS crops (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      planting_season TEXT,
      harvest_season TEXT,
      growth_days INTEGER,
      water_requirements REAL
    )
  `);

  // Table SoilTypeCrops (relation many-to-many)
  await dbPromisified.run(`
    CREATE TABLE IF NOT EXISTS soil_type_crops (
      soilTypeId TEXT NOT NULL,
      cropId TEXT NOT NULL,
      suitability REAL,
      PRIMARY KEY (soilTypeId, cropId),
      FOREIGN KEY (soilTypeId) REFERENCES soil_types(id),
      FOREIGN KEY (cropId) REFERENCES crops(id)
    )
  `);

  // Table CropActivities
  await dbPromisified.run(`
    CREATE TABLE IF NOT EXISTS crop_activities (
      id TEXT PRIMARY KEY,
      cropId TEXT NOT NULL,
      name TEXT NOT NULL,
      description TEXT,
      days_after_planting INTEGER,
      FOREIGN KEY (cropId) REFERENCES crops(id)
    )
  `);

  // Table WeatherAlerts
  await dbPromisified.run(`
    CREATE TABLE IF NOT EXISTS weather_alerts (
      id TEXT PRIMARY KEY,
      location TEXT NOT NULL,
      type TEXT NOT NULL,
      severity TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      startTime DATETIME NOT NULL,
      endTime DATETIME NOT NULL,
      recommendations TEXT,
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Table DocumentRecommendations (structure complète pour compatibilité Flutter)
  await dbPromisified.run(`
    CREATE TABLE IF NOT EXISTS document_recommendations (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT,
      category TEXT NOT NULL,
      region TEXT,
      prefecture TEXT,
      price REAL DEFAULT 0,
      filePath TEXT,
      fileSizeBytes INTEGER DEFAULT 0,
      fileExtension TEXT DEFAULT 'pdf',
      isActive INTEGER DEFAULT 1,
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Table Payments
  await dbPromisified.run(`
    CREATE TABLE IF NOT EXISTS payments (
      id TEXT PRIMARY KEY,
      userId TEXT NOT NULL,
      documentId TEXT,
      amount REAL NOT NULL,
      currency TEXT DEFAULT 'XOF',
      method TEXT NOT NULL,
      status TEXT DEFAULT 'pending',
      transactionId TEXT,
      phoneNumber TEXT,
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (userId) REFERENCES users(id)
    )
  `);

  // Table UserPurchases
  await dbPromisified.run(`
    CREATE TABLE IF NOT EXISTS user_purchases (
      id TEXT PRIMARY KEY,
      userId TEXT NOT NULL,
      documentId TEXT NOT NULL,
      paymentId TEXT,
      purchasedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (userId) REFERENCES users(id),
      FOREIGN KEY (documentId) REFERENCES document_recommendations(id),
      FOREIGN KEY (paymentId) REFERENCES payments(id)
    )
  `);

  // Table AgriculturalMetrics (structure complète pour compatibilité Flutter)
  await dbPromisified.run(`
    CREATE TABLE IF NOT EXISTS agricultural_metrics (
      id TEXT PRIMARY KEY,
      userId TEXT NOT NULL,
      cropType TEXT NOT NULL,
      region TEXT,
      plantingDate DATETIME,
      harvestDate DATETIME,
      plantedArea REAL,
      area REAL,
      expectedYield REAL,
      actualYield REAL,
      totalCost REAL,
      costPerHectare REAL,
      revenue REAL,
      profit REAL,
      status TEXT DEFAULT 'planted',
      yieldEfficiency REAL,
      daysToHarvest INTEGER,
      weatherData TEXT DEFAULT '{}',
      soilData TEXT DEFAULT '{}',
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (userId) REFERENCES users(id)
    )
  `);

  // NOTE: Les données de référence (régions, cultures, types de sols) doivent être fournies par l'admin
  // via l'interface d'administration ou les scripts admin
  // Aucune donnée inventée n'est chargée automatiquement
  console.log('📊 Base de données prête. Les données de référence doivent être fournies par l\'admin.');
};

