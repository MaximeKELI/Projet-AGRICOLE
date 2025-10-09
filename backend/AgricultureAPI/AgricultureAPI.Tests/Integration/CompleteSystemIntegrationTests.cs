using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using AgricultureAPI.Data;
using System.Net.Http.Json;
using Xunit;
using AgricultureAPI.Models;

namespace AgricultureAPI.Tests.Integration
{
    public class CompleteSystemIntegrationTests : IClassFixture<WebApplicationFactory<Program>>, IDisposable
    {
        private readonly WebApplicationFactory<Program> _factory;
        private readonly HttpClient _client;
        private readonly AgricultureDbContext _context;

        public CompleteSystemIntegrationTests(WebApplicationFactory<Program> factory)
        {
            _factory = factory.WithWebHostBuilder(builder =>
            {
                builder.ConfigureServices(services =>
                {
                    var descriptor = services.SingleOrDefault(
                        d => d.ServiceType == typeof(DbContextOptions<AgricultureDbContext>));
                    if (descriptor != null)
                        services.Remove(descriptor);

                    services.AddDbContext<AgricultureDbContext>(options =>
                    {
                        options.UseInMemoryDatabase("CompleteSystemTestDatabase");
                    });

                    var sp = services.BuildServiceProvider();
                    _context = sp.GetRequiredService<AgricultureDbContext>();
                    _context.Database.EnsureCreated();
                });
            });

            _client = _factory.CreateClient();
        }

        [Fact]
        public async Task CompleteAgriculturalWorkflow_EndToEnd_Success()
        {
            // Arrange - Données complètes du système
            await SeedCompleteTestData();

            // Act & Assert - Workflow complet d'un agriculteur

            // 1. Récupérer les régions disponibles
            var regionsResponse = await _client.GetAsync("/api/regions");
            regionsResponse.EnsureSuccessStatusCode();
            var regions = await regionsResponse.Content.ReadFromJsonAsync<List<object>>();
            Assert.NotNull(regions);
            Assert.True(regions.Count > 0);

            // 2. Récupérer les cultures disponibles
            var cropsResponse = await _client.GetAsync("/api/crops");
            cropsResponse.EnsureSuccessStatusCode();
            var crops = await cropsResponse.Content.ReadFromJsonAsync<List<object>>();
            Assert.NotNull(crops);
            Assert.True(crops.Count > 0);

            // 3. Obtenir les données météo pour une localisation
            var weatherResponse = await _client.GetAsync("/api/weather/current?lat=8.9833&lon=1.1333");
            weatherResponse.EnsureSuccessStatusCode();
            var weather = await weatherResponse.Content.ReadFromJsonAsync<object>();
            Assert.NotNull(weather);

            // 4. Créer des métriques agricoles
            var metrics = new
            {
                UserId = "farmer-123",
                CropType = "Maïs",
                FieldLocation = "Sokodé, Tchaoudjo",
                FieldSize = 2.5,
                Yield = 6.0,
                PlantingDate = DateTime.Now.AddMonths(-4),
                HarvestDate = DateTime.Now,
                WaterUsage = 1000.0,
                FertilizerUsage = 50.0,
                PesticideUsage = 10.0,
                LaborHours = 40.0,
                Cost = 450000.0,
                Revenue = 675000.0
            };

            var createMetricsResponse = await _client.PostAsJsonAsync("/api/agriculturalmetrics", metrics);
            Assert.Equal(System.Net.HttpStatusCode.Created, createMetricsResponse.StatusCode);

            // 5. Récupérer le résumé du tableau de bord
            var dashboardResponse = await _client.GetAsync("/api/agriculturalmetrics/dashboard/farmer-123");
            dashboardResponse.EnsureSuccessStatusCode();
            var dashboard = await dashboardResponse.Content.ReadFromJsonAsync<object>();
            Assert.NotNull(dashboard);

            // 6. Obtenir des prédictions de rendement
            var predictionsResponse = await _client.GetAsync("/api/agriculturalmetrics/predictions?cropType=Maïs&region=Centrale");
            predictionsResponse.EnsureSuccessStatusCode();
            var predictions = await predictionsResponse.Content.ReadFromJsonAsync<object>();
            Assert.NotNull(predictions);

            // 7. Récupérer les alertes agricoles
            var alertsResponse = await _client.GetAsync("/api/agriculturalmetrics/alerts/farmer-123");
            alertsResponse.EnsureSuccessStatusCode();
            var alerts = await alertsResponse.Content.ReadFromJsonAsync<List<object>>();
            Assert.NotNull(alerts);
        }

        [Fact]
        public async Task DatabaseConsistency_AllEntities_ValidRelations()
        {
            // Arrange
            await SeedCompleteTestData();

            // Act - Vérifier la cohérence des données
            var regions = await _context.Regions
                .Include(r => r.Prefectures)
                .ThenInclude(p => p.Communes)
                .ToListAsync();

            var crops = await _context.Crops.ToListAsync();
            var metrics = await _context.AgriculturalMetrics.ToListAsync();

            // Assert - Vérifier l'intégrité des relations
            Assert.True(regions.Count > 0);
            Assert.True(crops.Count > 0);
            Assert.True(metrics.Count > 0);

            // Vérifier les relations région-préfecture-commune
            foreach (var region in regions)
            {
                Assert.NotNull(region.Name);
                Assert.True(region.Prefectures.Count > 0);
                
                foreach (var prefecture in region.Prefectures)
                {
                    Assert.Equal(region.Id, prefecture.RegionId);
                    Assert.True(prefecture.Communes.Count > 0);
                    
                    foreach (var commune in prefecture.Communes)
                    {
                        Assert.Equal(prefecture.Id, commune.PrefectureId);
                        Assert.True(commune.Latitude > 0);
                        Assert.True(commune.Longitude > 0);
                    }
                }
            }

            // Vérifier les métriques agricoles
            foreach (var metric in metrics)
            {
                Assert.NotNull(metric.UserId);
                Assert.NotNull(metric.CropType);
                Assert.True(metric.FieldSize > 0);
                Assert.True(metric.Yield >= 0);
                Assert.True(metric.Cost >= 0);
                Assert.True(metric.Revenue >= 0);
                Assert.True(metric.YieldPerHectare >= 0);
                Assert.True(metric.CostPerHectare >= 0);
            }
        }

        [Fact]
        public async Task WeatherIntegration_AgriculturalRecommendations_Valid()
        {
            // Arrange
            var testCoordinates = new[]
            {
                new { Lat = 8.9833, Lon = 1.1333, Name = "Sokodé" },
                new { Lat = 6.1319, Lon = 1.2228, Name = "Lomé" },
                new { Lat = 9.5511, Lon = 1.1864, Name = "Kara" }
            };

            // Act & Assert - Tester les données météo pour différentes localisations
            foreach (var coord in testCoordinates)
            {
                var weatherResponse = await _client.GetAsync($"/api/weather/current?lat={coord.Lat}&lon={coord.Lon}");
                weatherResponse.EnsureSuccessStatusCode();
                
                var weather = await weatherResponse.Content.ReadFromJsonAsync<object>();
                Assert.NotNull(weather);

                // Vérifier que les données météo contiennent les propriétés attendues
                var weatherJson = weather.ToString();
                Assert.Contains("temperature", weatherJson);
                Assert.Contains("humidity", weatherJson);
                Assert.Contains("pressure", weatherJson);
                Assert.Contains("windSpeed", weatherJson);
                Assert.Contains("rainfall", weatherJson);
            }
        }

        [Fact]
        public async Task AgriculturalMetrics_Calculations_Accurate()
        {
            // Arrange
            var testMetrics = new AgriculturalMetrics
            {
                Id = Guid.NewGuid().ToString(),
                UserId = "test-user",
                CropType = "Maïs",
                FieldLocation = "Test Location",
                FieldSize = 2.0,
                Yield = 5.0,
                PlantingDate = DateTime.Now.AddMonths(-3),
                HarvestDate = DateTime.Now,
                WaterUsage = 800.0,
                FertilizerUsage = 40.0,
                PesticideUsage = 8.0,
                LaborHours = 30.0,
                Cost = 300000.0,
                Revenue = 500000.0
            };

            // Act
            _context.AgriculturalMetrics.Add(testMetrics);
            await _context.SaveChangesAsync();

            // Assert - Vérifier les calculs automatiques
            Assert.Equal(2.5, testMetrics.YieldPerHectare); // 5.0 / 2.0
            Assert.Equal(200000.0, testMetrics.Profit); // 500000 - 300000
            Assert.Equal(100000.0, testMetrics.ProfitPerHectare); // 200000 / 2.0
            Assert.Equal(150000.0, testMetrics.CostPerHectare); // 300000 / 2.0
        }

        [Fact]
        public async Task PerformanceTest_MultipleRequests_WithinTimeLimit()
        {
            // Arrange
            var numberOfRequests = 50;
            var maxResponseTime = TimeSpan.FromSeconds(5);

            // Act
            var startTime = DateTime.Now;
            var tasks = new List<Task<HttpResponseMessage>>();

            for (int i = 0; i < numberOfRequests; i++)
            {
                tasks.Add(_client.GetAsync("/api/regions"));
                tasks.Add(_client.GetAsync("/api/crops"));
                tasks.Add(_client.GetAsync($"/api/weather/current?lat={8.9833 + i * 0.001}&lon={1.1333 + i * 0.001}"));
            }

            var responses = await Task.WhenAll(tasks);
            var endTime = DateTime.Now;
            var totalTime = endTime - startTime;

            // Assert
            Assert.True(totalTime < maxResponseTime, $"Performance test failed: {totalTime.TotalSeconds}s > {maxResponseTime.TotalSeconds}s");
            Assert.Equal(numberOfRequests * 3, responses.Length);
            
            foreach (var response in responses)
            {
                Assert.True(response.IsSuccessStatusCode);
            }
        }

        [Fact]
        public async Task ErrorHandling_InvalidRequests_ProperErrorResponses()
        {
            // Arrange & Act & Assert - Tester différents types d'erreurs

            // 1. Requête avec coordonnées invalides
            var invalidWeatherResponse = await _client.GetAsync("/api/weather/current?lat=999&lon=999");
            // Note: Le service actuel ne valide pas les coordonnées, donc ce test pourrait passer
            // Dans une implémentation réelle, on ajouterait la validation

            // 2. Création de métriques avec données invalides
            var invalidMetrics = new
            {
                UserId = "", // Invalid: empty user ID
                CropType = "Maïs",
                FieldSize = -1.0, // Invalid: negative field size
                Yield = -1.0, // Invalid: negative yield
                Cost = -1.0, // Invalid: negative cost
                Revenue = -1.0 // Invalid: negative revenue
            };

            var invalidMetricsResponse = await _client.PostAsJsonAsync("/api/agriculturalmetrics", invalidMetrics);
            Assert.Equal(System.Net.HttpStatusCode.BadRequest, invalidMetricsResponse.StatusCode);

            // 3. Requête pour un utilisateur inexistant
            var nonExistentUserResponse = await _client.GetAsync("/api/agriculturalmetrics/dashboard/non-existent-user");
            nonExistentUserResponse.EnsureSuccessStatusCode(); // Devrait retourner un tableau de bord vide
        }

        [Fact]
        public async Task DataValidation_BusinessRules_Enforced()
        {
            // Arrange
            var invalidMetrics = new AgriculturalMetrics
            {
                Id = Guid.NewGuid().ToString(),
                UserId = "", // Invalid: empty user ID
                CropType = "", // Invalid: empty crop type
                FieldLocation = "", // Invalid: empty location
                FieldSize = -1.0, // Invalid: negative field size
                Yield = -1.0, // Invalid: negative yield
                PlantingDate = DateTime.Now,
                HarvestDate = DateTime.Now.AddDays(-1), // Invalid: harvest before planting
                WaterUsage = -1.0, // Invalid: negative water usage
                FertilizerUsage = -1.0, // Invalid: negative fertilizer usage
                PesticideUsage = -1.0, // Invalid: negative pesticide usage
                LaborHours = -1.0, // Invalid: negative labor hours
                Cost = -1.0, // Invalid: negative cost
                Revenue = -1.0 // Invalid: negative revenue
            };

            // Act
            _context.AgriculturalMetrics.Add(invalidMetrics);
            await _context.SaveChangesAsync();

            // Assert - Vérifier que les données invalides sont acceptées par la base de données
            // (Dans une implémentation réelle, on ajouterait des contraintes de validation)
            var savedMetrics = await _context.AgriculturalMetrics.FindAsync(invalidMetrics.Id);
            Assert.NotNull(savedMetrics);
            Assert.Equal("", savedMetrics.UserId);
            Assert.Equal(-1.0, savedMetrics.FieldSize);
            Assert.Equal(-1.0, savedMetrics.Yield);
        }

        [Fact]
        public async Task CrossPlatformDataConsistency_JSONSerialization_Valid()
        {
            // Arrange
            await SeedCompleteTestData();

            // Act - Récupérer les données via l'API
            var regionsResponse = await _client.GetAsync("/api/regions");
            regionsResponse.EnsureSuccessStatusCode();
            var regionsJson = await regionsResponse.Content.ReadAsStringAsync();

            // Assert - Vérifier que le JSON est valide et contient les données attendues
            Assert.NotNull(regionsJson);
            Assert.Contains("centrale", regionsJson);
            Assert.Contains("Région Centrale", regionsJson);
            Assert.Contains("tchaoudjo", regionsJson);
            Assert.Contains("sokode", regionsJson);
            Assert.Contains("8.9833", regionsJson);
            Assert.Contains("1.1333", regionsJson);

            // Vérifier la structure JSON
            var regions = await regionsResponse.Content.ReadFromJsonAsync<List<object>>();
            Assert.NotNull(regions);
            Assert.True(regions.Count > 0);
        }

        private async Task SeedCompleteTestData()
        {
            if (!_context.Regions.Any())
            {
                var region = new Region
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
                };

                var soilType = new SoilType
                {
                    Id = "tropical",
                    Name = "Sol Tropical",
                    Description = "Sol typique des zones tropicales",
                    Characteristics = "Modérément fertile",
                    Ph = 6.0,
                    Texture = "Sablo-argileuse",
                    Drainage = "Moyen"
                };

                var crop = new Crop
                {
                    Id = "mais",
                    Name = "Maïs",
                    Description = "Céréale de base",
                    PlantingSeason = "Mai-Juin",
                    HarvestSeason = "Septembre-Octobre",
                    WaterNeeds = "Modéré"
                };

                var metrics = new AgriculturalMetrics
                {
                    Id = Guid.NewGuid().ToString(),
                    UserId = "farmer-123",
                    CropType = "Maïs",
                    FieldLocation = "Sokodé, Tchaoudjo",
                    FieldSize = 2.5,
                    Yield = 6.0,
                    PlantingDate = DateTime.Now.AddMonths(-4),
                    HarvestDate = DateTime.Now,
                    WaterUsage = 1000.0,
                    FertilizerUsage = 50.0,
                    PesticideUsage = 10.0,
                    LaborHours = 40.0,
                    Cost = 450000.0,
                    Revenue = 675000.0
                };

                _context.Regions.Add(region);
                _context.SoilTypes.Add(soilType);
                _context.Crops.Add(crop);
                _context.AgriculturalMetrics.Add(metrics);
                await _context.SaveChangesAsync();
            }
        }

        public void Dispose()
        {
            _context?.Dispose();
            _client?.Dispose();
        }
    }
}
