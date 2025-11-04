import { getDb } from '../database/db.js';
import { v4 as uuidv4 } from 'uuid';

/**
 * Script d'administration pour gérer les données de référence
 * Ces données doivent être fournies par l'admin, pas générées automatiquement
 */

export class AdminDataManager {
  /**
   * Ajouter une région (doit être fait par l'admin)
   */
  static async addRegion(name, description) {
    const db = getDb();
    const id = uuidv4();
    await db.run(
      'INSERT INTO regions (id, name, description) VALUES (?, ?, ?)',
      [id, name, description]
    );
    return { id, name, description };
  }

  /**
   * Ajouter un type de sol (doit être fait par l'admin)
   */
  static async addSoilType(name, description, ph_min, ph_max, texture) {
    const db = getDb();
    const id = uuidv4();
    await db.run(
      'INSERT INTO soil_types (id, name, description, ph_min, ph_max, texture) VALUES (?, ?, ?, ?, ?, ?)',
      [id, name, description, ph_min, ph_max, texture]
    );
    return { id, name, description, ph_min, ph_max, texture };
  }

  /**
   * Ajouter une culture (doit être fait par l'admin)
   */
  static async addCrop(name, description, planting_season, harvest_season, growth_days, water_requirements) {
    const db = getDb();
    const id = uuidv4();
    await db.run(
      'INSERT INTO crops (id, name, description, planting_season, harvest_season, growth_days, water_requirements) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id, name, description, planting_season, harvest_season, growth_days, water_requirements]
    );
    return { id, name, description, planting_season, harvest_season, growth_days, water_requirements };
  }

  /**
   * Charger les données de référence depuis un fichier JSON (pour l'admin)
   * Exemple d'utilisation:
   * node -e "import('./admin/admin_data_manager.js').then(m => m.AdminDataManager.loadFromJson('./admin/reference_data.json'))"
   */
  static async loadFromJson(jsonData) {
    const results = {
      regions: [],
      soilTypes: [],
      crops: []
    };

    if (jsonData.regions) {
      for (const region of jsonData.regions) {
        const added = await this.addRegion(region.name, region.description);
        results.regions.push(added);
      }
    }

    if (jsonData.soilTypes) {
      for (const soil of jsonData.soilTypes) {
        const added = await this.addSoilType(
          soil.name,
          soil.description,
          soil.ph_min,
          soil.ph_max,
          soil.texture
        );
        results.soilTypes.push(added);
      }
    }

    if (jsonData.crops) {
      for (const crop of jsonData.crops) {
        const added = await this.addCrop(
          crop.name,
          crop.description,
          crop.planting_season,
          crop.harvest_season,
          crop.growth_days,
          crop.water_requirements
        );
        results.crops.push(added);
      }
    }

    return results;
  }
}

// Exemple de données de référence (à fournir par l'admin)
export const exampleReferenceData = {
  regions: [
    { name: 'Maritime', description: 'Région côtière du Togo' },
    { name: 'Plateaux', description: 'Région des plateaux' },
    { name: 'Centrale', description: 'Région centrale' },
    { name: 'Kara', description: 'Région de Kara' },
    { name: 'Savanes', description: 'Région des savanes' }
  ],
  soilTypes: [
    { name: 'Argileux', description: 'Sol argileux', ph_min: 6.0, ph_max: 7.5, texture: 'argile' },
    { name: 'Sableux', description: 'Sol sableux', ph_min: 5.5, ph_max: 7.0, texture: 'sable' },
    { name: 'Argilo-sableux', description: 'Sol argilo-sableux', ph_min: 6.0, ph_max: 7.0, texture: 'argilo-sableux' },
    { name: 'Limon', description: 'Sol limoneux', ph_min: 6.5, ph_max: 7.5, texture: 'limon' },
    { name: 'Latéritique', description: 'Sol latéritique', ph_min: 5.0, ph_max: 6.5, texture: 'latérite' }
  ],
  crops: [
    { name: 'Maïs', description: 'Maïs', planting_season: 'Mars-Avril', harvest_season: 'Juillet-Août', growth_days: 90, water_requirements: 500 },
    { name: 'Riz', description: 'Riz', planting_season: 'Mai-Juin', harvest_season: 'Octobre-Novembre', growth_days: 120, water_requirements: 1000 },
    { name: 'Arachide', description: 'Arachide', planting_season: 'Avril-Mai', harvest_season: 'Août-Septembre', growth_days: 90, water_requirements: 400 }
  ]
};

