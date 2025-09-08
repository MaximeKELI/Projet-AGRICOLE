using AgricultureAPI.Models;

namespace AgricultureAPI.Services
{
    public interface IWeatherService
    {
        Task<IEnumerable<WeatherAlert>> GetCurrentWeatherAlertsAsync();
        Task<IEnumerable<WeatherAlert>> GetAlertsByTypeAsync(string type);
        Task<WeatherAlert> CreateWeatherAlertAsync(WeatherAlert weatherAlert);
        Task<WeatherAlert> UpdateWeatherAlertAsync(WeatherAlert weatherAlert);
        Task DeleteWeatherAlertAsync(string id);
    }
}
