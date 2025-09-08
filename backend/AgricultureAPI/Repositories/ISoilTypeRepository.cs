using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public interface ISoilTypeRepository
    {
        Task<IEnumerable<SoilType>> GetAllAsync();
        Task<SoilType?> GetByIdAsync(string id);
        Task<SoilType> CreateAsync(SoilType soilType);
        Task<SoilType> UpdateAsync(SoilType soilType);
        Task DeleteAsync(string id);
        Task<IEnumerable<Crop>> GetSuitableCropsAsync(string soilTypeId);
    }
}
