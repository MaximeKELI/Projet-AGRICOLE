using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public interface IAgriculturalMetricsRepository
    {
        Task<IEnumerable<AgriculturalMetrics>> GetAllAsync();
        Task<AgriculturalMetrics?> GetByIdAsync(string id);
        Task<IEnumerable<AgriculturalMetrics>> GetByUserIdAsync(string userId);
        Task<IEnumerable<AgriculturalMetrics>> GetByCropTypeAndRegionAsync(string cropType, string region);
        Task<AgriculturalMetrics> CreateAsync(AgriculturalMetrics metric);
        Task<AgriculturalMetrics> UpdateAsync(AgriculturalMetrics metric);
        Task DeleteAsync(string id);
    }
}
