using AgricultureAPI.Models;
using AgricultureAPI.Repositories;
using AgricultureAPI.Services;
using Moq;
using Xunit;

namespace AgricultureAPI.Tests.Services
{
    public class WeatherServiceTests
    {
        private readonly Mock<IWeatherAlertRepository> _mockRepository;
        private readonly WeatherService _weatherService;

        public WeatherServiceTests()
        {
            _mockRepository = new Mock<IWeatherAlertRepository>();
            _weatherService = new WeatherService(_mockRepository.Object);
        }

        [Fact]
        public async Task GetCurrentWeatherAsync_ReturnsWeatherData()
        {
            // Arrange
            var lat = 6.1319;
            var lon = 1.2228;

            // Act
            var result = await _weatherService.GetCurrentWeatherAsync(lat, lon);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(lat, result.Latitude);
            Assert.Equal(lon, result.Longitude);
            Assert.True(result.Temperature >= 25 && result.Temperature <= 35);
            Assert.True(result.Humidity >= 60 && result.Humidity <= 90);
            Assert.True(result.Pressure >= 1013 && result.Pressure <= 1033);
            Assert.True(result.WindSpeed >= 0 && result.WindSpeed <= 30);
            Assert.True(result.WindDirection >= 0 && result.WindDirection <= 360);
            Assert.True(result.Rainfall >= 0 && result.Rainfall <= 5);
            Assert.True(result.UvIndex >= 0 && result.UvIndex <= 11);
        }

        [Fact]
        public async Task GetWeatherForecastAsync_ReturnsWeatherForecast()
        {
            // Arrange
            var lat = 6.1319;
            var lon = 1.2228;

            // Act
            var result = await _weatherService.GetWeatherForecastAsync(lat, lon);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(lat, result.Latitude);
            Assert.Equal(lon, result.Longitude);
            Assert.NotNull(result.DailyForecast);
            Assert.NotNull(result.HourlyForecast);
            Assert.NotNull(result.AgriculturalRecommendations);
        }

        [Fact]
        public async Task GetWeatherAlertsAsync_ReturnsAlerts()
        {
            // Arrange
            var lat = 6.1319;
            var lon = 1.2228;
            var alerts = new List<WeatherAlert>
            {
                new WeatherAlert
                {
                    Id = "alert1",
                    Type = "rain",
                    Severity = "medium",
                    Message = "Pluie modérée attendue",
                    StartDate = DateTime.Now,
                    EndDate = DateTime.Now.AddHours(2),
                    Recommendations = "Éviter les travaux agricoles"
                }
            };

            _mockRepository.Setup(repo => repo.GetActiveAlertsAsync())
                .ReturnsAsync(alerts);

            // Act
            var result = await _weatherService.GetWeatherAlertsAsync(lat, lon);

            // Assert
            Assert.NotNull(result);
            Assert.Single(result);
            Assert.Equal("alert1", result.First().Id);
        }

        [Fact]
        public async Task GetAgriculturalWeatherDataAsync_ReturnsCompleteData()
        {
            // Arrange
            var lat = 6.1319;
            var lon = 1.2228;

            // Act
            var result = await _weatherService.GetAgriculturalWeatherDataAsync(lat, lon);

            // Assert
            Assert.NotNull(result);
            // Vérifier que l'objet contient les propriétés attendues
            var resultType = result.GetType();
            Assert.True(resultType.GetProperty("weather") != null);
            Assert.True(resultType.GetProperty("agriculturalAdvice") != null);
            Assert.True(resultType.GetProperty("irrigationAdvice") != null);
            Assert.True(resultType.GetProperty("diseaseRisks") != null);
            Assert.True(resultType.GetProperty("isFavorableForPlanting") != null);
            Assert.True(resultType.GetProperty("isFavorableForHarvest") != null);
        }

        [Fact]
        public async Task CreateWeatherAlertAsync_ReturnsCreatedAlert()
        {
            // Arrange
            var alert = new WeatherAlert
            {
                Id = "new-alert",
                Type = "drought",
                Severity = "high",
                Message = "Sécheresse sévère",
                StartDate = DateTime.Now,
                EndDate = DateTime.Now.AddDays(7),
                Recommendations = "Irrigation d'urgence nécessaire"
            };

            _mockRepository.Setup(repo => repo.CreateAsync(It.IsAny<WeatherAlert>()))
                .ReturnsAsync(alert);

            // Act
            var result = await _weatherService.CreateWeatherAlertAsync(alert);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(alert.Id, result.Id);
            Assert.Equal(alert.Type, result.Type);
            Assert.Equal(alert.Severity, result.Severity);
        }
    }
}
