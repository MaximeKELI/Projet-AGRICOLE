using AgricultureAPI.Models;
using AgricultureAPI.Repositories;
using AgricultureAPI.Data;

namespace AgricultureAPI.Services
{
    public class AgricultureService : IAgricultureService
    {
        private readonly IRegionRepository _regionRepository;
        private readonly IPrefectureRepository _prefectureRepository;
        private readonly ICommuneRepository _communeRepository;
        private readonly ISoilTypeRepository _soilTypeRepository;
        private readonly ICropRepository _cropRepository;
        private readonly AgricultureDbContext _context;

        public AgricultureService(
            IRegionRepository regionRepository,
            IPrefectureRepository prefectureRepository,
            ICommuneRepository communeRepository,
            ISoilTypeRepository soilTypeRepository,
            ICropRepository cropRepository,
            AgricultureDbContext context)
        {
            _regionRepository = regionRepository;
            _prefectureRepository = prefectureRepository;
            _communeRepository = communeRepository;
            _soilTypeRepository = soilTypeRepository;
            _cropRepository = cropRepository;
            _context = context;
        }

        public async Task<IEnumerable<Region>> GetRegionsAsync()
        {
            return await _regionRepository.GetAllAsync();
        }

        public async Task<IEnumerable<Prefecture>> GetPrefecturesAsync(string regionId)
        {
            return await _regionRepository.GetPrefecturesAsync(regionId);
        }

        public async Task<IEnumerable<Commune>> GetCommunesAsync(string prefectureId)
        {
            return await _prefectureRepository.GetCommunesAsync(prefectureId);
        }

        public async Task<SoilType?> GetSoilTypeForCommuneAsync(string communeId)
        {
            var commune = await _communeRepository.GetByIdAsync(communeId);
            return commune?.SoilType;
        }

        public async Task<IEnumerable<Crop>> GetRecommendedCropsAsync(string soilTypeId)
        {
            return await _soilTypeRepository.GetSuitableCropsAsync(soilTypeId);
        }

        public async Task<Crop?> GetCropAsync(string cropId)
        {
            return await _cropRepository.GetByIdAsync(cropId);
        }

        public async Task<IEnumerable<CropActivity>> GetUpcomingActivitiesAsync(string cropId, DateTime plantingDate)
        {
            return await _cropRepository.GetUpcomingActivitiesAsync(cropId, plantingDate);
        }

        public async Task<IEnumerable<Commune>> GetCommunesByLocationAsync(double latitude, double longitude, double radiusKm)
        {
            return await _communeRepository.GetByLocationAsync(latitude, longitude, radiusKm);
        }

        public async Task SeedDataAsync()
        {
            // Vérifier si les données existent déjà
            var existingRegions = await _regionRepository.GetAllAsync();
            if (existingRegions.Any())
                return;

            // Créer les types de sols
            var soilTypes = new List<SoilType>
            {
                new SoilType
                {
                    Id = "ferralitique",
                    Name = "Sol Ferralitique",
                    Description = "Sol rouge riche en fer et aluminium",
                    Characteristics = "Bonne structure, bien drainé, acide",
                    Ph = 5.5,
                    Texture = "Argilo-sableuse",
                    Drainage = "Bon"
                },
                new SoilType
                {
                    Id = "sableux",
                    Name = "Sol Sableux",
                    Description = "Sol à dominante sableuse, bien drainé",
                    Characteristics = "Drainage rapide, faible rétention d'eau",
                    Ph = 6.0,
                    Texture = "Sableuse",
                    Drainage = "Très bon"
                },
                new SoilType
                {
                    Id = "argilo_sableux",
                    Name = "Sol Argilo-Sableux",
                    Description = "Sol équilibré entre argile et sable",
                    Characteristics = "Bonne rétention d'eau et de nutriments",
                    Ph = 6.5,
                    Texture = "Argilo-sableuse",
                    Drainage = "Moyen"
                },
                new SoilType
                {
                    Id = "volcanique",
                    Name = "Sol Volcanique",
                    Description = "Sol d'origine volcanique très fertile",
                    Characteristics = "Très fertile, riche en minéraux",
                    Ph = 6.8,
                    Texture = "Limoneuse",
                    Drainage = "Bon"
                },
                new SoilType
                {
                    Id = "tropical",
                    Name = "Sol Tropical",
                    Description = "Sol typique des zones tropicales",
                    Characteristics = "Modérément fertile, lessivé",
                    Ph = 6.0,
                    Texture = "Sablo-argileuse",
                    Drainage = "Moyen"
                },
                new SoilType
                {
                    Id = "lateritique",
                    Name = "Sol Latéritique",
                    Description = "Sol rouge à cuirasse latéritique",
                    Characteristics = "Dur en saison sèche, compact",
                    Ph = 5.8,
                    Texture = "Argileuse",
                    Drainage = "Faible"
                },
                new SoilType
                {
                    Id = "soudanien",
                    Name = "Sol Soudanien",
                    Description = "Sol des zones soudaniennes",
                    Characteristics = "Pauvre en matière organique",
                    Ph = 6.2,
                    Texture = "Sablo-limoneuse",
                    Drainage = "Bon"
                }
            };

            foreach (var soilType in soilTypes)
            {
                await _soilTypeRepository.CreateAsync(soilType);
            }

            // Créer les cultures
            var crops = new List<Crop>
            {
                new Crop
                {
                    Id = "mais",
                    Name = "Maïs",
                    Description = "Céréale de base très nutritive",
                    GrowthDurationDays = 120,
                    PlantingSeason = "Avril-Juin"
                },
                new Crop
                {
                    Id = "riz",
                    Name = "Riz",
                    Description = "Céréale cultivée en zone humide",
                    GrowthDurationDays = 140,
                    PlantingSeason = "Mai-Juillet"
                },
                new Crop
                {
                    Id = "arachide",
                    Name = "Arachide",
                    Description = "Légumineuse oléagineuse",
                    GrowthDurationDays = 110,
                    PlantingSeason = "Mai-Juin"
                }
            };

            foreach (var crop in crops)
            {
                await _cropRepository.CreateAsync(crop);
            }

            // Créer les régions avec leurs préfectures et communes
            var regions = new List<Region>
            {
                new Region
                {
                    Id = "maritime",
                    Name = "Région Maritime",
                    Prefectures = new List<Prefecture>
                    {
                        new Prefecture
                        {
                            Id = "golfe",
                            Name = "Golfe",
                            RegionId = "maritime",
                            Communes = new List<Commune>
                            {
                                new Commune
                                {
                                    Id = "lome",
                                    Name = "Lomé",
                                    PrefectureId = "golfe",
                                    SoilTypeId = "ferralitique",
                                    Latitude = 6.1319,
                                    Longitude = 1.2228
                                },
                                new Commune
                                {
                                    Id = "aneho",
                                    Name = "Aného",
                                    PrefectureId = "golfe",
                                    SoilTypeId = "sableux",
                                    Latitude = 6.2333,
                                    Longitude = 1.5833
                                }
                            }
                        },
                        new Prefecture
                        {
                            Id = "lacs",
                            Name = "Lacs",
                            RegionId = "maritime",
                            Communes = new List<Commune>
                            {
                                new Commune
                                {
                                    Id = "tsevie",
                                    Name = "Tsévié",
                                    PrefectureId = "lacs",
                                    SoilTypeId = "argilo_sableux",
                                    Latitude = 6.4286,
                                    Longitude = 1.2134
                                }
                            }
                        }
                    }
                },
                new Region
                {
                    Id = "plateaux",
                    Name = "Région des Plateaux",
                    Prefectures = new List<Prefecture>
                    {
                        new Prefecture
                        {
                            Id = "kloto",
                            Name = "Kloto",
                            RegionId = "plateaux",
                            Communes = new List<Commune>
                            {
                                new Commune
                                {
                                    Id = "kpalime",
                                    Name = "Kpalimé",
                                    PrefectureId = "kloto",
                                    SoilTypeId = "ferralitique",
                                    Latitude = 6.9000,
                                    Longitude = 0.6333
                                }
                            }
                        },
                        new Prefecture
                        {
                            Id = "agou",
                            Name = "Agou",
                            RegionId = "plateaux",
                            Communes = new List<Commune>
                            {
                                new Commune
                                {
                                    Id = "agou",
                                    Name = "Agou",
                                    PrefectureId = "agou",
                                    SoilTypeId = "volcanique",
                                    Latitude = 6.8500,
                                    Longitude = 0.7833
                                }
                            }
                        }
                    }
                },
                new Region
                {
                    Id = "centrale",
                    Name = "Région Centrale",
                    Prefectures = new List<Prefecture>
                    {
                        new Prefecture
                        {
                            Id = "tchaoudjo",
                            Name = "Tchaoudjo",
                            RegionId = "centrale",
                            Communes = new List<Commune>
                            {
                                new Commune
                                {
                                    Id = "sokode",
                                    Name = "Sokodé",
                                    PrefectureId = "tchaoudjo",
                                    SoilTypeId = "tropical",
                                    Latitude = 8.9833,
                                    Longitude = 1.1333
                                }
                            }
                        }
                    }
                },
                new Region
                {
                    Id = "kara",
                    Name = "Région de la Kara",
                    Prefectures = new List<Prefecture>
                    {
                        new Prefecture
                        {
                            Id = "kozah",
                            Name = "Kozah",
                            RegionId = "kara",
                            Communes = new List<Commune>
                            {
                                new Commune
                                {
                                    Id = "kara",
                                    Name = "Kara",
                                    PrefectureId = "kozah",
                                    SoilTypeId = "lateritique",
                                    Latitude = 9.5511,
                                    Longitude = 1.1864
                                }
                            }
                        }
                    }
                },
                new Region
                {
                    Id = "savanes",
                    Name = "Région des Savanes",
                    Prefectures = new List<Prefecture>
                    {
                        new Prefecture
                        {
                            Id = "tandjoare",
                            Name = "Tandjoareé",
                            RegionId = "savanes",
                            Communes = new List<Commune>
                            {
                                new Commune
                                {
                                    Id = "dapaong",
                                    Name = "Dapaong",
                                    PrefectureId = "tandjoare",
                                    SoilTypeId = "soudanien",
                                    Latitude = 10.8667,
                                    Longitude = 0.2167
                                }
                            }
                        }
                    }
                }
            };

            foreach (var region in regions)
            {
                await _regionRepository.CreateAsync(region);
            }

            // Créer les relations sol-culture
            var soilTypeCrops = new List<SoilTypeCrop>
            {
                // Maïs
                new SoilTypeCrop { SoilTypeId = "argilo_sableux", CropId = "mais" },
                new SoilTypeCrop { SoilTypeId = "tropical", CropId = "mais" },
                new SoilTypeCrop { SoilTypeId = "volcanique", CropId = "mais" },
                
                // Riz
                new SoilTypeCrop { SoilTypeId = "argilo_sableux", CropId = "riz" },
                new SoilTypeCrop { SoilTypeId = "tropical", CropId = "riz" },
                
                // Arachide
                new SoilTypeCrop { SoilTypeId = "sableux", CropId = "arachide" },
                new SoilTypeCrop { SoilTypeId = "lateritique", CropId = "arachide" },
                new SoilTypeCrop { SoilTypeId = "soudanien", CropId = "arachide" }
            };

            // Ajouter les relations sol-culture
            foreach (var soilTypeCrop in soilTypeCrops)
            {
                _context.SoilTypeCrops.Add(soilTypeCrop);
            }
            await _context.SaveChangesAsync();

            // Créer les activités pour le maïs
            var maisActivities = new List<CropActivity>
            {
                new CropActivity
                {
                    Id = "mais_prep_terrain",
                    Name = "Préparation du terrain",
                    Description = "Labour et hersage du terrain",
                    DayFromPlanting = -15,
                    Category = "preparation",
                    CropId = "mais"
                },
                new CropActivity
                {
                    Id = "mais_semis",
                    Name = "Semis",
                    Description = "Plantation des graines de maïs",
                    DayFromPlanting = 0,
                    Category = "planting",
                    IsReminder = true,
                    CropId = "mais"
                },
                new CropActivity
                {
                    Id = "mais_sarclage1",
                    Name = "Premier sarclage",
                    Description = "Désherbage et buttage",
                    DayFromPlanting = 21,
                    Category = "maintenance",
                    IsReminder = true,
                    CropId = "mais"
                },
                new CropActivity
                {
                    Id = "mais_fertilisation",
                    Name = "Fertilisation",
                    Description = "Application d'engrais NPK",
                    DayFromPlanting = 30,
                    Category = "maintenance",
                    IsReminder = true,
                    CropId = "mais"
                },
                new CropActivity
                {
                    Id = "mais_recolte",
                    Name = "Récolte",
                    Description = "Récolte des épis de maïs",
                    DayFromPlanting = 120,
                    Category = "harvest",
                    IsReminder = true,
                    CropId = "mais"
                }
            };

            foreach (var activity in maisActivities)
            {
                _context.CropActivities.Add(activity);
            }
            await _context.SaveChangesAsync();

            // Créer les calendriers de plantation
            var plantingSchedules = new List<PlantingSchedule>
            {
                new PlantingSchedule
                {
                    CropId = "mais",
                    OptimalStartDate = new DateTime(2024, 4, 15),
                    OptimalEndDate = new DateTime(2024, 6, 30),
                    ClimateConsiderations = "Éviter les périodes de forte pluie pour le semis"
                },
                new PlantingSchedule
                {
                    CropId = "riz",
                    OptimalStartDate = new DateTime(2024, 5, 1),
                    OptimalEndDate = new DateTime(2024, 7, 31),
                    ClimateConsiderations = "Nécessite une bonne disponibilité en eau"
                },
                new PlantingSchedule
                {
                    CropId = "arachide",
                    OptimalStartDate = new DateTime(2024, 5, 15),
                    OptimalEndDate = new DateTime(2024, 6, 30),
                    ClimateConsiderations = "Éviter l'excès d'humidité"
                }
            };

            foreach (var schedule in plantingSchedules)
            {
                _context.PlantingSchedules.Add(schedule);
            }
            await _context.SaveChangesAsync();
        }
    }
}
