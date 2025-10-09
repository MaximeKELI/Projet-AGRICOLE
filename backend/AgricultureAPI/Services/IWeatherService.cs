using AgricultureAPI.Models;

namespace AgricultureAPI.Services
{
    public interface IWeatherService
    {
        Task<WeatherData> GetCurrentWeatherAsync(double lat, double lon);
        Task<WeatherForecast> GetWeatherForecastAsync(double lat, double lon);
        Task<IEnumerable<WeatherAlert>> GetWeatherAlertsAsync(double lat, double lon);
        Task<object> GetAgriculturalWeatherDataAsync(double lat, double lon);
        Task<IEnumerable<WeatherAlert>> GetCurrentWeatherAlertsAsync();
        Task<IEnumerable<WeatherAlert>> GetAlertsByTypeAsync(string type);
        Task<WeatherAlert> CreateWeatherAlertAsync(WeatherAlert weatherAlert);
        Task<WeatherAlert> UpdateWeatherAlertAsync(WeatherAlert weatherAlert);
        Task DeleteWeatherAlertAsync(string id);
    }
}
