using Microsoft.EntityFrameworkCore;
using AgricultureAPI.Data;
using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public class WeatherAlertRepository : IWeatherAlertRepository
    {
        private readonly AgricultureDbContext _context;

        public WeatherAlertRepository(AgricultureDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<WeatherAlert>> GetAllAsync()
        {
            return await _context.WeatherAlerts
                .OrderByDescending(wa => wa.StartDate)
                .ToListAsync();
        }

        public async Task<WeatherAlert?> GetByIdAsync(string id)
        {
            return await _context.WeatherAlerts
                .FirstOrDefaultAsync(wa => wa.Id == id);
        }

        public async Task<WeatherAlert> CreateAsync(WeatherAlert weatherAlert)
        {
            _context.WeatherAlerts.Add(weatherAlert);
            await _context.SaveChangesAsync();
            return weatherAlert;
        }

        public async Task<WeatherAlert> UpdateAsync(WeatherAlert weatherAlert)
        {
            _context.Entry(weatherAlert).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return weatherAlert;
        }

        public async Task DeleteAsync(string id)
        {
            var weatherAlert = await _context.WeatherAlerts.FindAsync(id);
            if (weatherAlert != null)
            {
                _context.WeatherAlerts.Remove(weatherAlert);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<IEnumerable<WeatherAlert>> GetActiveAlertsAsync()
        {
            var now = DateTime.Now;
            return await _context.WeatherAlerts
                .Where(wa => wa.StartDate <= now && (wa.EndDate == null || wa.EndDate >= now))
                .OrderByDescending(wa => wa.StartDate)
                .ToListAsync();
        }

        public async Task<IEnumerable<WeatherAlert>> GetAlertsByTypeAsync(string type)
        {
            return await _context.WeatherAlerts
                .Where(wa => wa.Type == type)
                .OrderByDescending(wa => wa.StartDate)
                .ToListAsync();
        }
    }
}
