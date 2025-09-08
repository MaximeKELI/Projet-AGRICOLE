using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public interface ICropRepository
    {
        Task<IEnumerable<Crop>> GetAllAsync();
        Task<Crop?> GetByIdAsync(string id);
        Task<Crop> CreateAsync(Crop crop);
        Task<Crop> UpdateAsync(Crop crop);
        Task DeleteAsync(string id);
        Task<IEnumerable<CropActivity>> GetActivitiesAsync(string cropId);
        Task<IEnumerable<CropActivity>> GetUpcomingActivitiesAsync(string cropId, DateTime plantingDate);
    }
}
