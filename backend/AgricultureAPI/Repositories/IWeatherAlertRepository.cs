using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public interface IWeatherAlertRepository
    {
        Task<IEnumerable<WeatherAlert>> GetAllAsync();
        Task<WeatherAlert?> GetByIdAsync(string id);
        Task<WeatherAlert> CreateAsync(WeatherAlert weatherAlert);
        Task<WeatherAlert> UpdateAsync(WeatherAlert weatherAlert);
        Task DeleteAsync(string id);
        Task<IEnumerable<WeatherAlert>> GetActiveAlertsAsync();
        Task<IEnumerable<WeatherAlert>> GetAlertsByTypeAsync(string type);
    }
}
