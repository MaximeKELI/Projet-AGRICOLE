using AgricultureAPI.Models;
using AgricultureAPI.Repositories;

namespace AgricultureAPI.Services
{
    public class WeatherService : IWeatherService
    {
        private readonly IWeatherAlertRepository _weatherAlertRepository;

        public WeatherService(IWeatherAlertRepository weatherAlertRepository)
        {
            _weatherAlertRepository = weatherAlertRepository;
        }

        public async Task<WeatherData> GetCurrentWeatherAsync(double lat, double lon)
        {
            // Simulation de données météo pour le développement
            var random = new Random();
            return new WeatherData
            {
                Id = Guid.NewGuid().ToString(),
                Location = $"Location {lat:F2}, {lon:F2}",
                Latitude = lat,
                Longitude = lon,
                Temperature = 25 + random.NextDouble() * 10, // 25-35°C
                Humidity = 60 + random.NextDouble() * 30, // 60-90%
                Pressure = 1013 + random.NextDouble() * 20, // 1013-1033 hPa
                WindSpeed = random.NextDouble() * 30, // 0-30 km/h
                WindDirection = random.NextDouble() * 360, // 0-360°
                Rainfall = random.NextDouble() * 5, // 0-5 mm
                UvIndex = random.NextDouble() * 11, // 0-11
                Condition = "Ensoleillé",
                Description = "Conditions favorables pour l'agriculture",
                Timestamp = DateTime.UtcNow,
                Forecast = "{}"
            };
        }

        public async Task<WeatherForecast> GetWeatherForecastAsync(double lat, double lon)
        {
            return new WeatherForecast
            {
                Id = Guid.NewGuid().ToString(),
                Location = $"Location {lat:F2}, {lon:F2}",
                Latitude = lat,
                Longitude = lon,
                DailyForecast = "[]",
                HourlyForecast = "[]",
                AgriculturalRecommendations = "{}",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }

        public async Task<IEnumerable<WeatherAlert>> GetWeatherAlertsAsync(double lat, double lon)
        {
            return await _weatherAlertRepository.GetActiveAlertsAsync();
        }

        public async Task<object> GetAgriculturalWeatherDataAsync(double lat, double lon)
        {
            var weatherData = await GetCurrentWeatherAsync(lat, lon);
            
            return new
            {
                weather = weatherData,
                agriculturalAdvice = weatherData.AgriculturalAdvice,
                irrigationAdvice = weatherData.IrrigationAdvice,
                diseaseRisks = weatherData.DiseaseRisk,
                isFavorableForPlanting = weatherData.IsFavorableForPlanting,
                isFavorableForHarvest = weatherData.IsFavorableForHarvest
            };
        }

        public async Task<IEnumerable<WeatherAlert>> GetCurrentWeatherAlertsAsync()
        {
            return await _weatherAlertRepository.GetActiveAlertsAsync();
        }

        public async Task<IEnumerable<WeatherAlert>> GetAlertsByTypeAsync(string type)
        {
            return await _weatherAlertRepository.GetAlertsByTypeAsync(type);
        }

        public async Task<WeatherAlert> CreateWeatherAlertAsync(WeatherAlert weatherAlert)
        {
            return await _weatherAlertRepository.CreateAsync(weatherAlert);
        }

        public async Task<WeatherAlert> UpdateWeatherAlertAsync(WeatherAlert weatherAlert)
        {
            return await _weatherAlertRepository.UpdateAsync(weatherAlert);
        }

        public async Task DeleteWeatherAlertAsync(string id)
        {
            await _weatherAlertRepository.DeleteAsync(id);
        }
    }
}
