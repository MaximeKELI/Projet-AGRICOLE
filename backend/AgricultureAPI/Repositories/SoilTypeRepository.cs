using Microsoft.EntityFrameworkCore;
using AgricultureAPI.Data;
using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public class SoilTypeRepository : ISoilTypeRepository
    {
        private readonly AgricultureDbContext _context;

        public SoilTypeRepository(AgricultureDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<SoilType>> GetAllAsync()
        {
            return await _context.SoilTypes
                .Include(s => s.Communes)
                .Include(s => s.SoilTypeCrops)
                .ThenInclude(sc => sc.Crop)
                .ToListAsync();
        }

        public async Task<SoilType?> GetByIdAsync(string id)
        {
            return await _context.SoilTypes
                .Include(s => s.Communes)
                .Include(s => s.SoilTypeCrops)
                .ThenInclude(sc => sc.Crop)
                .FirstOrDefaultAsync(s => s.Id == id);
        }

        public async Task<SoilType> CreateAsync(SoilType soilType)
        {
            _context.SoilTypes.Add(soilType);
            await _context.SaveChangesAsync();
            return soilType;
        }

        public async Task<SoilType> UpdateAsync(SoilType soilType)
        {
            _context.Entry(soilType).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return soilType;
        }

        public async Task DeleteAsync(string id)
        {
            var soilType = await _context.SoilTypes.FindAsync(id);
            if (soilType != null)
            {
                _context.SoilTypes.Remove(soilType);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<IEnumerable<Crop>> GetSuitableCropsAsync(string soilTypeId)
        {
            return await _context.SoilTypeCrops
                .Where(sc => sc.SoilTypeId == soilTypeId)
                .Select(sc => sc.Crop)
                .Include(c => c.Activities)
                .Include(c => c.PlantingSchedule)
                .ToListAsync();
        }
    }
}
