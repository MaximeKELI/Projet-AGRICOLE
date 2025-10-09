using AgricultureAPI.Models;
using AgricultureAPI.Repositories;
using AgricultureAPI.Services;
using Moq;
using Xunit;

namespace AgricultureAPI.Tests.Services
{
    public class AgriculturalMetricsServiceTests
    {
        private readonly Mock<IAgriculturalMetricsRepository> _mockRepository;
        private readonly AgriculturalMetricsService _service;

        public AgriculturalMetricsServiceTests()
        {
            _mockRepository = new Mock<IAgriculturalMetricsRepository>();
            _service = new AgriculturalMetricsService(_mockRepository.Object);
        }

        [Fact]
        public async Task GetUserMetricsAsync_WithValidUserId_ReturnsMetrics()
        {
            // Arrange
            var userId = "user123";
            var metrics = new List<AgriculturalMetrics>
            {
                new AgriculturalMetrics
                {
                    Id = "metric1",
                    UserId = userId,
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
                }
            };

            _mockRepository.Setup(repo => repo.GetByUserIdAsync(userId))
                .ReturnsAsync(metrics);

            // Act
            var result = await _service.GetUserMetricsAsync(userId);

            // Assert
            Assert.NotNull(result);
            Assert.Single(result);
            Assert.Equal(userId, result.First().UserId);
        }

        [Fact]
        public async Task GetUserMetricsAsync_WithInvalidUserId_ThrowsArgumentException()
        {
            // Arrange
            var invalidUserId = "";

            // Act & Assert
            await Assert.ThrowsAsync<ArgumentException>(() => 
                _service.GetUserMetricsAsync(invalidUserId));
        }

        [Fact]
        public async Task CreateMetricAsync_WithValidMetric_ReturnsCreatedMetric()
        {
            // Arrange
            var metric = new AgriculturalMetrics
            {
                UserId = "user123",
                CropType = "Riz",
                FieldLocation = "Lomé",
                FieldSize = 1.0,
                Yield = 3.0,
                PlantingDate = DateTime.Now.AddMonths(-4),
                HarvestDate = DateTime.Now,
                WaterUsage = 800,
                FertilizerUsage = 30,
                PesticideUsage = 5,
                LaborHours = 25,
                Cost = 300000,
                Revenue = 450000
            };

            _mockRepository.Setup(repo => repo.CreateAsync(It.IsAny<AgriculturalMetrics>()))
                .ReturnsAsync(metric);

            // Act
            var result = await _service.CreateMetricAsync(metric);

            // Assert
            Assert.NotNull(result);
            Assert.NotEmpty(result.Id);
            Assert.Equal(metric.UserId, result.UserId);
            Assert.Equal(metric.CropType, result.CropType);
        }

        [Fact]
        public async Task CreateMetricAsync_WithNullMetric_ThrowsArgumentNullException()
        {
            // Act & Assert
            await Assert.ThrowsAsync<ArgumentNullException>(() => 
                _service.CreateMetricAsync(null!));
        }

        [Fact]
        public async Task CreateMetricAsync_WithEmptyUserId_ThrowsArgumentException()
        {
            // Arrange
            var metric = new AgriculturalMetrics
            {
                UserId = "",
                CropType = "Maïs"
            };

            // Act & Assert
            await Assert.ThrowsAsync<ArgumentException>(() => 
                _service.CreateMetricAsync(metric));
        }

        [Fact]
        public async Task GetDashboardSummaryAsync_WithValidUserId_ReturnsSummary()
        {
            // Arrange
            var userId = "user123";
            var metrics = new List<AgriculturalMetrics>
            {
                new AgriculturalMetrics
                {
                    Id = "metric1",
                    UserId = userId,
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
                },
                new AgriculturalMetrics
                {
                    Id = "metric2",
                    UserId = userId,
                    CropType = "Riz",
                    FieldLocation = "Lomé",
                    FieldSize = 1.0,
                    Yield = 3.0,
                    PlantingDate = DateTime.Now.AddMonths(-4),
                    HarvestDate = DateTime.Now,
                    WaterUsage = 800,
                    FertilizerUsage = 30,
                    PesticideUsage = 5,
                    LaborHours = 25,
                    Cost = 300000,
                    Revenue = 450000
                }
            };

            _mockRepository.Setup(repo => repo.GetByUserIdAsync(userId))
                .ReturnsAsync(metrics);

            // Act
            var result = await _service.GetDashboardSummaryAsync(userId);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(2, result.TotalFields);
            Assert.Equal(3.5, result.TotalArea);
            Assert.Equal(8.0, result.TotalYield);
            Assert.Equal(1200000, result.TotalRevenue);
            Assert.Equal(800000, result.TotalCost);
            Assert.Equal(400000, result.TotalProfit);
            Assert.Equal(2.29, Math.Round(result.AverageYieldPerHectare, 2), 2);
            Assert.Equal(114285.71, Math.Round(result.AverageProfitPerHectare, 2), 2);
        }

        [Fact]
        public async Task GetYieldPredictionsAsync_WithValidParameters_ReturnsPredictions()
        {
            // Arrange
            var cropType = "Maïs";
            var region = "Centrale";
            var historicalData = new List<AgriculturalMetrics>
            {
                new AgriculturalMetrics
                {
                    CropType = cropType,
                    FieldLocation = region,
                    FieldSize = 1.0,
                    Yield = 2.0,
                    HarvestDate = DateTime.Now.AddMonths(-6)
                },
                new AgriculturalMetrics
                {
                    CropType = cropType,
                    FieldLocation = region,
                    FieldSize = 1.0,
                    Yield = 2.5,
                    HarvestDate = DateTime.Now.AddMonths(-3)
                }
            };

            _mockRepository.Setup(repo => repo.GetByCropTypeAndRegionAsync(cropType, region))
                .ReturnsAsync(historicalData);

            // Act
            var result = await _service.GetYieldPredictionsAsync(cropType, region);

            // Assert
            Assert.NotNull(result);
            var resultType = result.GetType();
            Assert.True(resultType.GetProperty("prediction") != null);
            Assert.True(resultType.GetProperty("confidence") != null);
            Assert.True(resultType.GetProperty("trend") != null);
            Assert.True(resultType.GetProperty("historicalAverage") != null);
            Assert.True(resultType.GetProperty("dataPoints") != null);
        }

        [Fact]
        public async Task GetAgriculturalAlertsAsync_WithValidUserId_ReturnsAlerts()
        {
            // Arrange
            var userId = "user123";
            var metrics = new List<AgriculturalMetrics>
            {
                new AgriculturalMetrics
                {
                    Id = "metric1",
                    UserId = userId,
                    CropType = "Maïs",
                    FieldSize = 1.0,
                    Yield = 1.5, // Low yield
                    Cost = 600000, // High cost
                    Revenue = 400000, // Loss
                    HarvestDate = DateTime.Now
                }
            };

            _mockRepository.Setup(repo => repo.GetByUserIdAsync(userId))
                .ReturnsAsync(metrics);

            // Act
            var result = await _service.GetAgriculturalAlertsAsync(userId);

            // Assert
            Assert.NotNull(result);
            var alerts = result.ToList();
            Assert.True(alerts.Count >= 2); // Should have low yield and loss alerts
        }
    }
}
