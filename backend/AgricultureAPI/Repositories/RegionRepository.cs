using Microsoft.EntityFrameworkCore;
using AgricultureAPI.Data;
using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public class RegionRepository : IRegionRepository
    {
        private readonly AgricultureDbContext _context;

        public RegionRepository(AgricultureDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Region>> GetAllAsync()
        {
            return await _context.Regions
                .Include(r => r.Prefectures)
                .ThenInclude(p => p.Communes)
                .ThenInclude(c => c.SoilType)
                .ToListAsync();
        }

        public async Task<Region?> GetByIdAsync(string id)
        {
            return await _context.Regions
                .Include(r => r.Prefectures)
                .ThenInclude(p => p.Communes)
                .ThenInclude(c => c.SoilType)
                .FirstOrDefaultAsync(r => r.Id == id);
        }

        public async Task<Region> CreateAsync(Region region)
        {
            _context.Regions.Add(region);
            await _context.SaveChangesAsync();
            return region;
        }

        public async Task<Region> UpdateAsync(Region region)
        {
            _context.Entry(region).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return region;
        }

        public async Task DeleteAsync(string id)
        {
            var region = await _context.Regions.FindAsync(id);
            if (region != null)
            {
                _context.Regions.Remove(region);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<IEnumerable<Prefecture>> GetPrefecturesAsync(string regionId)
        {
            return await _context.Prefectures
                .Include(p => p.Communes)
                .ThenInclude(c => c.SoilType)
                .Where(p => p.RegionId == regionId)
                .ToListAsync();
        }
    }
}
