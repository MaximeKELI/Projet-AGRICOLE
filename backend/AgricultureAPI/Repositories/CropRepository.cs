using Microsoft.EntityFrameworkCore;
using AgricultureAPI.Data;
using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public class CropRepository : ICropRepository
    {
        private readonly AgricultureDbContext _context;

        public CropRepository(AgricultureDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Crop>> GetAllAsync()
        {
            return await _context.Crops
                .Include(c => c.Activities)
                .Include(c => c.PlantingSchedule)
                .Include(c => c.SoilTypeCrops)
                .ThenInclude(sc => sc.SoilType)
                .ToListAsync();
        }

        public async Task<Crop?> GetByIdAsync(string id)
        {
            return await _context.Crops
                .Include(c => c.Activities)
                .Include(c => c.PlantingSchedule)
                .Include(c => c.SoilTypeCrops)
                .ThenInclude(sc => sc.SoilType)
                .FirstOrDefaultAsync(c => c.Id == id);
        }

        public async Task<Crop> CreateAsync(Crop crop)
        {
            _context.Crops.Add(crop);
            await _context.SaveChangesAsync();
            return crop;
        }

        public async Task<Crop> UpdateAsync(Crop crop)
        {
            _context.Entry(crop).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return crop;
        }

        public async Task DeleteAsync(string id)
        {
            var crop = await _context.Crops.FindAsync(id);
            if (crop != null)
            {
                _context.Crops.Remove(crop);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<IEnumerable<CropActivity>> GetActivitiesAsync(string cropId)
        {
            return await _context.CropActivities
                .Where(ca => ca.CropId == cropId)
                .OrderBy(ca => ca.DayFromPlanting)
                .ToListAsync();
        }

        public async Task<IEnumerable<CropActivity>> GetUpcomingActivitiesAsync(string cropId, DateTime plantingDate)
        {
            var now = DateTime.Now;
            return await _context.CropActivities
                .Where(ca => ca.CropId == cropId && ca.IsReminder)
                .ToListAsync()
                .ContinueWith(task =>
                {
                    return task.Result.Where(activity =>
                    {
                        var activityDate = plantingDate.AddDays(activity.DayFromPlanting);
                        return activityDate > now;
                    });
                });
        }
    }
}
