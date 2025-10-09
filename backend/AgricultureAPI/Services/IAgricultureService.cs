using AgricultureAPI.Models;

namespace AgricultureAPI.Services
{
    public interface IAgricultureService
    {
        Task<IEnumerable<Region>> GetRegionsAsync();
        Task<IEnumerable<Prefecture>> GetPrefecturesAsync(string regionId);
        Task<IEnumerable<Commune>> GetCommunesAsync(string prefectureId);
        Task<IEnumerable<Commune>> GetCommunesByRegionAsync(string regionId);
        Task<SoilType?> GetSoilTypeForCommuneAsync(string communeId);
        Task<IEnumerable<Crop>> GetCropsAsync();
        Task<IEnumerable<Crop>> GetRecommendedCropsAsync(string soilTypeId);
        Task<Crop?> GetCropAsync(string cropId);
        Task<IEnumerable<CropActivity>> GetUpcomingActivitiesAsync(string cropId, DateTime plantingDate);
        Task<IEnumerable<Commune>> GetCommunesByLocationAsync(double latitude, double longitude, double radiusKm);
        Task SeedDataAsync();
    }
}
