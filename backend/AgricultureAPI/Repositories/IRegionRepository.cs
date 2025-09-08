using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public interface IRegionRepository
    {
        Task<IEnumerable<Region>> GetAllAsync();
        Task<Region?> GetByIdAsync(string id);
        Task<Region> CreateAsync(Region region);
        Task<Region> UpdateAsync(Region region);
        Task DeleteAsync(string id);
        Task<IEnumerable<Prefecture>> GetPrefecturesAsync(string regionId);
    }
}
