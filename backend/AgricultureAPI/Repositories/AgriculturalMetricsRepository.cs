using AgricultureAPI.Data;
using AgricultureAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace AgricultureAPI.Repositories
{
    public class AgriculturalMetricsRepository : IAgriculturalMetricsRepository
    {
        private readonly AgricultureDbContext _context;

        public AgriculturalMetricsRepository(AgricultureDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<AgriculturalMetrics>> GetAllAsync()
        {
            return await _context.AgriculturalMetrics.ToListAsync();
        }

        public async Task<AgriculturalMetrics?> GetByIdAsync(string id)
        {
            return await _context.AgriculturalMetrics.FindAsync(id);
        }

        public async Task<IEnumerable<AgriculturalMetrics>> GetByUserIdAsync(string userId)
        {
            return await _context.AgriculturalMetrics
                .Where(m => m.UserId == userId)
                .OrderByDescending(m => m.CreatedAt)
                .ToListAsync();
        }

        public async Task<IEnumerable<AgriculturalMetrics>> GetByCropTypeAndRegionAsync(string cropType, string region)
        {
            return await _context.AgriculturalMetrics
                .Where(m => m.CropType == cropType && m.FieldLocation.Contains(region))
                .OrderByDescending(m => m.HarvestDate)
                .ToListAsync();
        }

        public async Task<AgriculturalMetrics> CreateAsync(AgriculturalMetrics metric)
        {
            _context.AgriculturalMetrics.Add(metric);
            await _context.SaveChangesAsync();
            return metric;
        }

        public async Task<AgriculturalMetrics> UpdateAsync(AgriculturalMetrics metric)
        {
            _context.AgriculturalMetrics.Update(metric);
            await _context.SaveChangesAsync();
            return metric;
        }

        public async Task DeleteAsync(string id)
        {
            var metric = await _context.AgriculturalMetrics.FindAsync(id);
            if (metric != null)
            {
                _context.AgriculturalMetrics.Remove(metric);
                await _context.SaveChangesAsync();
            }
        }
    }
}
