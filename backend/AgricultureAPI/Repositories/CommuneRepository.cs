using Microsoft.EntityFrameworkCore;
using AgricultureAPI.Data;
using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public class CommuneRepository : ICommuneRepository
    {
        private readonly AgricultureDbContext _context;

        public CommuneRepository(AgricultureDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Commune>> GetAllAsync()
        {
            return await _context.Communes
                .Include(c => c.Prefecture)
                .ThenInclude(p => p.Region)
                .Include(c => c.SoilType)
                .ToListAsync();
        }

        public async Task<Commune?> GetByIdAsync(string id)
        {
            return await _context.Communes
                .Include(c => c.Prefecture)
                .ThenInclude(p => p.Region)
                .Include(c => c.SoilType)
                .FirstOrDefaultAsync(c => c.Id == id);
        }

        public async Task<Commune> CreateAsync(Commune commune)
        {
            _context.Communes.Add(commune);
            await _context.SaveChangesAsync();
            return commune;
        }

        public async Task<Commune> UpdateAsync(Commune commune)
        {
            _context.Entry(commune).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return commune;
        }

        public async Task DeleteAsync(string id)
        {
            var commune = await _context.Communes.FindAsync(id);
            if (commune != null)
            {
                _context.Communes.Remove(commune);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<IEnumerable<Commune>> GetByLocationAsync(double latitude, double longitude, double radiusKm)
        {
            // Calcul approximatif de distance (pour une recherche plus précise, utiliser une fonction de distance géographique)
            var latRange = radiusKm / 111.0; // 1 degré ≈ 111 km
            var lonRange = radiusKm / (111.0 * Math.Cos(latitude * Math.PI / 180.0));

            return await _context.Communes
                .Include(c => c.Prefecture)
                .ThenInclude(p => p.Region)
                .Include(c => c.SoilType)
                .Where(c => Math.Abs(c.Latitude - latitude) <= latRange &&
                           Math.Abs(c.Longitude - longitude) <= lonRange)
                .ToListAsync();
        }
    }
}
