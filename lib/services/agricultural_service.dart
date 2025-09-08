import '../models/agricultural_data.dart';

class AgriculturalService {
  static final AgriculturalService _instance = AgriculturalService._internal();
  factory AgriculturalService() => _instance;
  AgriculturalService._internal() {
    _initializeData();
  }

  // Données du Togo - Régions, Préfectures et Communes
  late final List<Region> _togoRegions;

  void _initializeData() {
    _togoRegions = [
      Region(
        id: 'maritime',
        name: 'Région Maritime',
        prefectures: [
          Prefecture(
            id: 'golfe',
            name: 'Golfe',
            regionId: 'maritime',
            communes: [
              Commune(
                id: 'lome',
                name: 'Lomé',
                prefectureId: 'golfe',
                latitude: 6.1319,
                longitude: 1.2228,
                soilType: _getSoilType('ferralitique'),
              ),
              Commune(
                id: 'aneho',
                name: 'Aného',
                prefectureId: 'golfe',
                latitude: 6.2333,
                longitude: 1.5833,
                soilType: _getSoilType('sableux'),
              ),
            ],
          ),
          Prefecture(
            id: 'lacs',
            name: 'Lacs',
            regionId: 'maritime',
            communes: [
              Commune(
                id: 'tsevie',
                name: 'Tsévié',
                prefectureId: 'lacs',
                latitude: 6.4286,
                longitude: 1.2134,
                soilType: _getSoilType('argilo_sableux'),
              ),
            ],
          ),
        ],
      ),
      Region(
        id: 'plateaux',
        name: 'Région des Plateaux',
        prefectures: [
          Prefecture(
            id: 'kloto',
            name: 'Kloto',
            regionId: 'plateaux',
            communes: [
              Commune(
                id: 'kpalime',
                name: 'Kpalimé',
                prefectureId: 'kloto',
                latitude: 6.9000,
                longitude: 0.6333,
                soilType: _getSoilType('ferralitique'),
              ),
            ],
          ),
          Prefecture(
            id: 'agou',
            name: 'Agou',
            regionId: 'plateaux',
            communes: [
              Commune(
                id: 'agou',
                name: 'Agou',
                prefectureId: 'agou',
                latitude: 6.8500,
                longitude: 0.7833,
                soilType: _getSoilType('volcanique'),
              ),
            ],
          ),
        ],
      ),
      Region(
        id: 'centrale',
        name: 'Région Centrale',
        prefectures: [
          Prefecture(
            id: 'tchaoudjo',
            name: 'Tchaoudjo',
            regionId: 'centrale',
            communes: [
              Commune(
                id: 'sokode',
                name: 'Sokodé',
                prefectureId: 'tchaoudjo',
                latitude: 8.9833,
                longitude: 1.1333,
                soilType: _getSoilType('tropical'),
              ),
            ],
          ),
        ],
      ),
      Region(
        id: 'kara',
        name: 'Région de la Kara',
        prefectures: [
          Prefecture(
            id: 'kozah',
            name: 'Kozah',
            regionId: 'kara',
            communes: [
              Commune(
                id: 'kara',
                name: 'Kara',
                prefectureId: 'kozah',
                latitude: 9.5511,
                longitude: 1.1864,
                soilType: _getSoilType('lateritique'),
              ),
            ],
          ),
        ],
      ),
      Region(
        id: 'savanes',
        name: 'Région des Savanes',
        prefectures: [
          Prefecture(
            id: 'tandjoare',
            name: 'Tandjoareé',
            regionId: 'savanes',
            communes: [
              Commune(
                id: 'dapaong',
                name: 'Dapaong',
                prefectureId: 'tandjoare',
                latitude: 10.8667,
                longitude: 0.2167,
                soilType: _getSoilType('soudanien'),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  // Types de sols du Togo
  final Map<String, SoilType> _soilTypes = {
    'ferralitique': SoilType(
      id: 'ferralitique',
      name: 'Sol Ferralitique',
      description: 'Sol rouge riche en fer et aluminium',
      characteristics: 'Bonne structure, bien drainé, acide',
      ph: 5.5,
      texture: 'Argilo-sableuse',
      drainage: 'Bon',
      suitableCrops: ['cacao', 'cafe', 'palmier_huile', 'manioc', 'igname'],
    ),
    'sableux': SoilType(
      id: 'sableux',
      name: 'Sol Sableux',
      description: 'Sol à dominante sableuse, bien drainé',
      characteristics: 'Drainage rapide, faible rétention d\'eau',
      ph: 6.0,
      texture: 'Sableuse',
      drainage: 'Très bon',
      suitableCrops: ['arachide', 'niebe', 'mil', 'sorgho', 'pastèque'],
    ),
    'argilo_sableux': SoilType(
      id: 'argilo_sableux',
      name: 'Sol Argilo-Sableux',
      description: 'Sol équilibré entre argile et sable',
      characteristics: 'Bonne rétention d\'eau et de nutriments',
      ph: 6.5,
      texture: 'Argilo-sableuse',
      drainage: 'Moyen',
      suitableCrops: ['maïs', 'riz', 'tomate', 'gombo', 'haricot'],
    ),
    'volcanique': SoilType(
      id: 'volcanique',
      name: 'Sol Volcanique',
      description: 'Sol d\'origine volcanique très fertile',
      characteristics: 'Très fertile, riche en minéraux',
      ph: 6.8,
      texture: 'Limoneuse',
      drainage: 'Bon',
      suitableCrops: ['cafe', 'banane', 'avocat', 'légumes', 'fleurs'],
    ),
    'tropical': SoilType(
      id: 'tropical',
      name: 'Sol Tropical',
      description: 'Sol typique des zones tropicales',
      characteristics: 'Modérément fertile, lessivé',
      ph: 6.0,
      texture: 'Sablo-argileuse',
      drainage: 'Moyen',
      suitableCrops: ['coton', 'soja', 'sésame', 'tournesol', 'mil'],
    ),
    'lateritique': SoilType(
      id: 'lateritique',
      name: 'Sol Latéritique',
      description: 'Sol rouge à cuirasse latéritique',
      characteristics: 'Dur en saison sèche, compact',
      ph: 5.8,
      texture: 'Argileuse',
      drainage: 'Faible',
      suitableCrops: ['sorgho', 'mil', 'arachide', 'niebe', 'sésame'],
    ),
    'soudanien': SoilType(
      id: 'soudanien',
      name: 'Sol Soudanien',
      description: 'Sol des zones soudaniennes',
      characteristics: 'Pauvre en matière organique',
      ph: 6.2,
      texture: 'Sablo-limoneuse',
      drainage: 'Bon',
      suitableCrops: ['mil', 'sorgho', 'arachide', 'niebe', 'sésame'],
    ),
  };

  // Cultures disponibles
  final Map<String, Crop> _crops = {
    'maïs': Crop(
      id: 'maïs',
      name: 'Maïs',
      description: 'Céréale de base très nutritive',
      suitableSoilTypes: ['argilo_sableux', 'tropical', 'volcanique'],
      growthDurationDays: 120,
      plantingSeason: 'Avril-Juin',
      technicalItinerary: TechnicalItinerary(
        cropId: 'maïs',
        activities: [
          CropActivity(
            id: 'prep_terrain',
            name: 'Préparation du terrain',
            description: 'Labour et hersage du terrain',
            dayFromPlanting: -15,
            category: 'preparation',
          ),
          CropActivity(
            id: 'semis',
            name: 'Semis',
            description: 'Plantation des graines de maïs',
            dayFromPlanting: 0,
            category: 'planting',
            isReminder: true,
          ),
          CropActivity(
            id: 'sarclage1',
            name: 'Premier sarclage',
            description: 'Désherbage et buttage',
            dayFromPlanting: 21,
            category: 'maintenance',
            isReminder: true,
          ),
          CropActivity(
            id: 'fertilisation',
            name: 'Fertilisation',
            description: 'Application d\'engrais NPK',
            dayFromPlanting: 30,
            category: 'maintenance',
            isReminder: true,
          ),
          CropActivity(
            id: 'sarclage2',
            name: 'Deuxième sarclage',
            description: 'Désherbage et buttage',
            dayFromPlanting: 45,
            category: 'maintenance',
            isReminder: true,
          ),
          CropActivity(
            id: 'recolte',
            name: 'Récolte',
            description: 'Récolte des épis de maïs',
            dayFromPlanting: 120,
            category: 'harvest',
            isReminder: true,
          ),
        ],
        plantingSchedule: PlantingSchedule(
          cropId: 'maïs',
          optimalStartDate: DateTime(2024, 4, 15),
          optimalEndDate: DateTime(2024, 6, 30),
          climateConsiderations: 'Éviter les périodes de forte pluie pour le semis',
        ),
      ),
    ),
    'riz': Crop(
      id: 'riz',
      name: 'Riz',
      description: 'Céréale cultivée en zone humide',
      suitableSoilTypes: ['argilo_sableux', 'tropical'],
      growthDurationDays: 140,
      plantingSeason: 'Mai-Juillet',
      technicalItinerary: TechnicalItinerary(
        cropId: 'riz',
        activities: [
          CropActivity(
            id: 'prep_pepiniere',
            name: 'Préparation pépinière',
            description: 'Préparation des pépinières de riz',
            dayFromPlanting: -30,
            category: 'preparation',
          ),
          CropActivity(
            id: 'semis_pepiniere',
            name: 'Semis en pépinière',
            description: 'Semis des graines en pépinière',
            dayFromPlanting: -25,
            category: 'planting',
          ),
          CropActivity(
            id: 'prep_riziere',
            name: 'Préparation rizière',
            description: 'Labour et mise en eau de la rizière',
            dayFromPlanting: -7,
            category: 'preparation',
          ),
          CropActivity(
            id: 'repiquage',
            name: 'Repiquage',
            description: 'Transplantation des plants de riz',
            dayFromPlanting: 0,
            category: 'planting',
            isReminder: true,
          ),
          CropActivity(
            id: 'desherbage1',
            name: 'Premier désherbage',
            description: 'Élimination des mauvaises herbes',
            dayFromPlanting: 20,
            category: 'maintenance',
            isReminder: true,
          ),
          CropActivity(
            id: 'fertilisation',
            name: 'Fertilisation',
            description: 'Application d\'engrais urée',
            dayFromPlanting: 35,
            category: 'maintenance',
            isReminder: true,
          ),
          CropActivity(
            id: 'desherbage2',
            name: 'Deuxième désherbage',
            description: 'Désherbage et entretien',
            dayFromPlanting: 50,
            category: 'maintenance',
            isReminder: true,
          ),
          CropActivity(
            id: 'recolte',
            name: 'Récolte',
            description: 'Récolte du riz',
            dayFromPlanting: 140,
            category: 'harvest',
            isReminder: true,
          ),
        ],
        plantingSchedule: PlantingSchedule(
          cropId: 'riz',
          optimalStartDate: DateTime(2024, 5, 1),
          optimalEndDate: DateTime(2024, 7, 31),
          climateConsiderations: 'Nécessite une bonne disponibilité en eau',
        ),
      ),
    ),
    'arachide': Crop(
      id: 'arachide',
      name: 'Arachide',
      description: 'Légumineuse oléagineuse',
      suitableSoilTypes: ['sableux', 'lateritique', 'soudanien'],
      growthDurationDays: 110,
      plantingSeason: 'Mai-Juin',
      technicalItinerary: TechnicalItinerary(
        cropId: 'arachide',
        activities: [
          CropActivity(
            id: 'prep_terrain',
            name: 'Préparation du terrain',
            description: 'Labour léger du terrain',
            dayFromPlanting: -10,
            category: 'preparation',
          ),
          CropActivity(
            id: 'semis',
            name: 'Semis',
            description: 'Plantation des graines d\'arachide',
            dayFromPlanting: 0,
            category: 'planting',
            isReminder: true,
          ),
          CropActivity(
            id: 'sarclage1',
            name: 'Premier sarclage',
            description: 'Désherbage léger',
            dayFromPlanting: 25,
            category: 'maintenance',
            isReminder: true,
          ),
          CropActivity(
            id: 'buttage',
            name: 'Buttage',
            description: 'Buttage des plants',
            dayFromPlanting: 45,
            category: 'maintenance',
            isReminder: true,
          ),
          CropActivity(
            id: 'sarclage2',
            name: 'Deuxième sarclage',
            description: 'Désherbage et entretien',
            dayFromPlanting: 65,
            category: 'maintenance',
            isReminder: true,
          ),
          CropActivity(
            id: 'recolte',
            name: 'Récolte',
            description: 'Arrachage des plants d\'arachide',
            dayFromPlanting: 110,
            category: 'harvest',
            isReminder: true,
          ),
        ],
        plantingSchedule: PlantingSchedule(
          cropId: 'arachide',
          optimalStartDate: DateTime(2024, 5, 15),
          optimalEndDate: DateTime(2024, 6, 30),
          climateConsiderations: 'Éviter l\'excès d\'humidité',
        ),
      ),
    ),
  };

  List<Region> getRegions() => _togoRegions;

  List<Prefecture> getPrefectures(String regionId) {
    final region = _togoRegions.firstWhere((r) => r.id == regionId);
    return region.prefectures;
  }

  List<Commune> getCommunes(String prefectureId) {
    for (final region in _togoRegions) {
      for (final prefecture in region.prefectures) {
        if (prefecture.id == prefectureId) {
          return prefecture.communes;
        }
      }
    }
    return [];
  }

  SoilType _getSoilType(String soilTypeId) {
    return _soilTypes[soilTypeId]!;
  }

  SoilType? getSoilTypeForCommune(String communeId) {
    for (final region in _togoRegions) {
      for (final prefecture in region.prefectures) {
        for (final commune in prefecture.communes) {
          if (commune.id == communeId) {
            return commune.soilType;
          }
        }
      }
    }
    return null;
  }

  List<Crop> getRecommendedCrops(String soilTypeId) {
    return _crops.values
        .where((crop) => crop.suitableSoilTypes.contains(soilTypeId))
        .toList();
  }

  Crop? getCrop(String cropId) {
    return _crops[cropId];
  }

  List<CropActivity> getUpcomingActivities(String cropId, DateTime plantingDate) {
    final crop = _crops[cropId];
    if (crop == null) return [];

    final now = DateTime.now();
    return crop.technicalItinerary.activities
        .where((activity) {
          final activityDate = plantingDate.add(Duration(days: activity.dayFromPlanting));
          return activityDate.isAfter(now) && activity.isReminder;
        })
        .toList();
  }

  List<WeatherAlert> getCurrentWeatherAlerts() {
    // Simulation d'alertes météo
    return [
      WeatherAlert(
        id: 'alert_1',
        type: 'rain',
        severity: 'medium',
        message: 'Fortes pluies prévues dans les prochains jours',
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 3)),
        recommendations: 'Éviter les travaux de semis. Protéger les cultures sensibles.',
      ),
    ];
  }
}
