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
