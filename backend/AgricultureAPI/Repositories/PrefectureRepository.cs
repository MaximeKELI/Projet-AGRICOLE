using Microsoft.EntityFrameworkCore;
using AgricultureAPI.Data;
using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public class PrefectureRepository : IPrefectureRepository
    {
        private readonly AgricultureDbContext _context;

        public PrefectureRepository(AgricultureDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Prefecture>> GetAllAsync()
        {
            return await _context.Prefectures
                .Include(p => p.Region)
                .Include(p => p.Communes)
                .ThenInclude(c => c.SoilType)
                .ToListAsync();
        }

        public async Task<Prefecture?> GetByIdAsync(string id)
        {
            return await _context.Prefectures
                .Include(p => p.Region)
                .Include(p => p.Communes)
                .ThenInclude(c => c.SoilType)
                .FirstOrDefaultAsync(p => p.Id == id);
        }

        public async Task<Prefecture> CreateAsync(Prefecture prefecture)
        {
            _context.Prefectures.Add(prefecture);
            await _context.SaveChangesAsync();
            return prefecture;
        }

        public async Task<Prefecture> UpdateAsync(Prefecture prefecture)
        {
            _context.Entry(prefecture).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return prefecture;
        }

        public async Task DeleteAsync(string id)
        {
            var prefecture = await _context.Prefectures.FindAsync(id);
            if (prefecture != null)
            {
                _context.Prefectures.Remove(prefecture);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<IEnumerable<Commune>> GetCommunesAsync(string prefectureId)
        {
            return await _context.Communes
                .Include(c => c.SoilType)
                .Where(c => c.PrefectureId == prefectureId)
                .ToListAsync();
        }
    }
}
