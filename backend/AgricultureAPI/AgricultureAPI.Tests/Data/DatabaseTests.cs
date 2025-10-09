using Microsoft.EntityFrameworkCore;
using AgricultureAPI.Data;
using AgricultureAPI.Models;
using Xunit;

namespace AgricultureAPI.Tests.Data
{
    public class DatabaseTests : IDisposable
    {
        private readonly AgricultureDbContext _context;

        public DatabaseTests()
        {
            var options = new DbContextOptionsBuilder<AgricultureDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;

            _context = new AgricultureDbContext(options);
        }

        [Fact]
        public async Task Database_CanCreateRegion()
        {
            // Arrange
            var region = new Region
            {
                Id = "test-region",
                Name = "Test Region"
            };

            // Act
            _context.Regions.Add(region);
            await _context.SaveChangesAsync();

            // Assert
            var savedRegion = await _context.Regions.FindAsync("test-region");
            Assert.NotNull(savedRegion);
            Assert.Equal("Test Region", savedRegion.Name);
        }

        [Fact]
        public async Task Database_CanCreatePrefectureWithRegion()
        {
            // Arrange
            var region = new Region
            {
                Id = "test-region",
                Name = "Test Region"
            };

            var prefecture = new Prefecture
            {
                Id = "test-prefecture",
                Name = "Test Prefecture",
                RegionId = "test-region",
                Region = region
            };

            // Act
            _context.Regions.Add(region);
            _context.Prefectures.Add(prefecture);
            await _context.SaveChangesAsync();

            // Assert
            var savedPrefecture = await _context.Prefectures
                .Include(p => p.Region)
                .FirstOrDefaultAsync(p => p.Id == "test-prefecture");
            
            Assert.NotNull(savedPrefecture);
            Assert.Equal("Test Prefecture", savedPrefecture.Name);
            Assert.NotNull(savedPrefecture.Region);
            Assert.Equal("Test Region", savedPrefecture.Region.Name);
        }

        [Fact]
        public async Task Database_CanCreateCommuneWithPrefectureAndSoilType()
        {
            // Arrange
            var region = new Region
            {
                Id = "test-region",
                Name = "Test Region"
            };

            var prefecture = new Prefecture
            {
                Id = "test-prefecture",
                Name = "Test Prefecture",
                RegionId = "test-region",
                Region = region
            };

            var soilType = new SoilType
            {
                Id = "test-soil",
                Name = "Test Soil",
                Description = "Test soil description",
                Characteristics = "Test characteristics",
                Ph = 6.5,
                Texture = "Sandy",
                Drainage = "Good"
            };

            var commune = new Commune
            {
                Id = "test-commune",
                Name = "Test Commune",
                PrefectureId = "test-prefecture",
                Prefecture = prefecture,
                SoilTypeId = "test-soil",
                SoilType = soilType,
                Latitude = 6.1319,
                Longitude = 1.2228
            };

            // Act
            _context.Regions.Add(region);
            _context.Prefectures.Add(prefecture);
            _context.SoilTypes.Add(soilType);
            _context.Communes.Add(commune);
            await _context.SaveChangesAsync();

            // Assert
            var savedCommune = await _context.Communes
                .Include(c => c.Prefecture)
                .ThenInclude(p => p.Region)
                .Include(c => c.SoilType)
                .FirstOrDefaultAsync(c => c.Id == "test-commune");

            Assert.NotNull(savedCommune);
            Assert.Equal("Test Commune", savedCommune.Name);
            Assert.Equal(6.1319, savedCommune.Latitude);
            Assert.Equal(1.2228, savedCommune.Longitude);
            Assert.NotNull(savedCommune.Prefecture);
            Assert.NotNull(savedCommune.SoilType);
        }

        [Fact]
        public async Task Database_CanCreateCrop()
        {
            // Arrange
            var crop = new Crop
            {
                Id = "test-crop",
                Name = "Test Crop",
                Description = "Test crop description",
                PlantingSeason = "Spring",
                HarvestSeason = "Fall",
                WaterNeeds = "Moderate",
                SoilTypes = new List<SoilTypeCrop>()
            };

            // Act
            _context.Crops.Add(crop);
            await _context.SaveChangesAsync();

            // Assert
            var savedCrop = await _context.Crops.FindAsync("test-crop");
            Assert.NotNull(savedCrop);
            Assert.Equal("Test Crop", savedCrop.Name);
            Assert.Equal("Spring", savedCrop.PlantingSeason);
            Assert.Equal("Fall", savedCrop.HarvestSeason);
        }

        [Fact]
        public async Task Database_CanCreateWeatherAlert()
        {
            // Arrange
            var alert = new WeatherAlert
            {
                Id = "test-alert",
                Type = "rain",
                Severity = "medium",
                Message = "Moderate rain expected",
                StartDate = DateTime.Now,
                EndDate = DateTime.Now.AddHours(2),
                Recommendations = "Avoid outdoor activities"
            };

            // Act
            _context.WeatherAlerts.Add(alert);
            await _context.SaveChangesAsync();

            // Assert
            var savedAlert = await _context.WeatherAlerts.FindAsync("test-alert");
            Assert.NotNull(savedAlert);
            Assert.Equal("rain", savedAlert.Type);
            Assert.Equal("medium", savedAlert.Severity);
            Assert.Equal("Moderate rain expected", savedAlert.Message);
        }

        [Fact]
        public async Task Database_CanCreateAgriculturalMetrics()
        {
            // Arrange
            var metrics = new AgriculturalMetrics
            {
                Id = "test-metrics",
                UserId = "user123",
                CropType = "Maïs",
                FieldLocation = "Sokodé",
                FieldSize = 2.5,
                Yield = 5.0,
                PlantingDate = DateTime.Now.AddMonths(-3),
                HarvestDate = DateTime.Now,
                WaterUsage = 1000,
                FertilizerUsage = 50,
                PesticideUsage = 10,
                LaborHours = 40,
                Cost = 500000,
                Revenue = 750000
            };

            // Act
            _context.AgriculturalMetrics.Add(metrics);
            await _context.SaveChangesAsync();

            // Assert
            var savedMetrics = await _context.AgriculturalMetrics.FindAsync("test-metrics");
            Assert.NotNull(savedMetrics);
            Assert.Equal("user123", savedMetrics.UserId);
            Assert.Equal("Maïs", savedMetrics.CropType);
            Assert.Equal(2.5, savedMetrics.FieldSize);
            Assert.Equal(5.0, savedMetrics.Yield);
            Assert.Equal(2.0, savedMetrics.YieldPerHectare);
            Assert.Equal(250000, savedMetrics.Profit);
            Assert.Equal(100000, savedMetrics.ProfitPerHectare);
            Assert.Equal(200000, savedMetrics.CostPerHectare);
        }

        [Fact]
        public async Task Database_CanQueryRegionsWithPrefectures()
        {
            // Arrange
            var region = new Region
            {
                Id = "test-region",
                Name = "Test Region",
                Prefectures = new List<Prefecture>
                {
                    new Prefecture
                    {
                        Id = "prefecture1",
                        Name = "Prefecture 1",
                        RegionId = "test-region"
                    },
                    new Prefecture
                    {
                        Id = "prefecture2",
                        Name = "Prefecture 2",
                        RegionId = "test-region"
                    }
                }
            };

            _context.Regions.Add(region);
            await _context.SaveChangesAsync();

            // Act
            var result = await _context.Regions
                .Include(r => r.Prefectures)
                .FirstOrDefaultAsync(r => r.Id == "test-region");

            // Assert
            Assert.NotNull(result);
            Assert.Equal(2, result.Prefectures.Count);
            Assert.Contains(result.Prefectures, p => p.Name == "Prefecture 1");
            Assert.Contains(result.Prefectures, p => p.Name == "Prefecture 2");
        }

        [Fact]
        public async Task Database_CanQueryAgriculturalMetricsByUser()
        {
            // Arrange
            var userId = "user123";
            var metrics1 = new AgriculturalMetrics
            {
                Id = "metrics1",
                UserId = userId,
                CropType = "Maïs",
                FieldSize = 1.0,
                Yield = 2.0,
                Cost = 100000,
                Revenue = 150000
            };

            var metrics2 = new AgriculturalMetrics
            {
                Id = "metrics2",
                UserId = userId,
                CropType = "Riz",
                FieldSize = 2.0,
                Yield = 4.0,
                Cost = 200000,
                Revenue = 300000
            };

            var metrics3 = new AgriculturalMetrics
            {
                Id = "metrics3",
                UserId = "user456",
                CropType = "Blé",
                FieldSize = 1.5,
                Yield = 3.0,
                Cost = 150000,
                Revenue = 225000
            };

            _context.AgriculturalMetrics.AddRange(metrics1, metrics2, metrics3);
            await _context.SaveChangesAsync();

            // Act
            var userMetrics = await _context.AgriculturalMetrics
                .Where(m => m.UserId == userId)
                .ToListAsync();

            // Assert
            Assert.Equal(2, userMetrics.Count);
            Assert.All(userMetrics, m => Assert.Equal(userId, m.UserId));
        }

        [Fact]
        public async Task Database_CanCalculateAggregatedMetrics()
        {
            // Arrange
            var userId = "user123";
            var metrics = new List<AgriculturalMetrics>
            {
                new AgriculturalMetrics
                {
                    Id = "metrics1",
                    UserId = userId,
                    CropType = "Maïs",
                    FieldSize = 2.0,
                    Yield = 4.0,
                    Cost = 200000,
                    Revenue = 300000
                },
                new AgriculturalMetrics
                {
                    Id = "metrics2",
                    UserId = userId,
                    CropType = "Riz",
                    FieldSize = 1.0,
                    Yield = 2.0,
                    Cost = 100000,
                    Revenue = 150000
                }
            };

            _context.AgriculturalMetrics.AddRange(metrics);
            await _context.SaveChangesAsync();

            // Act
            var aggregated = await _context.AgriculturalMetrics
                .Where(m => m.UserId == userId)
                .GroupBy(m => m.UserId)
                .Select(g => new
                {
                    TotalFields = g.Count(),
                    TotalArea = g.Sum(m => m.FieldSize),
                    TotalYield = g.Sum(m => m.Yield),
                    TotalCost = g.Sum(m => m.Cost),
                    TotalRevenue = g.Sum(m => m.Revenue),
                    TotalProfit = g.Sum(m => m.Revenue - m.Cost)
                })
                .FirstOrDefaultAsync();

            // Assert
            Assert.NotNull(aggregated);
            Assert.Equal(2, aggregated.TotalFields);
            Assert.Equal(3.0, aggregated.TotalArea);
            Assert.Equal(6.0, aggregated.TotalYield);
            Assert.Equal(300000, aggregated.TotalCost);
            Assert.Equal(450000, aggregated.TotalRevenue);
            Assert.Equal(150000, aggregated.TotalProfit);
        }

        public void Dispose()
        {
            _context.Dispose();
        }
    }
}
