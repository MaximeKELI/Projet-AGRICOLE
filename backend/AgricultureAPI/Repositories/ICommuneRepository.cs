using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public interface ICommuneRepository
    {
        Task<IEnumerable<Commune>> GetAllAsync();
        Task<Commune?> GetByIdAsync(string id);
        Task<Commune> CreateAsync(Commune commune);
        Task<Commune> UpdateAsync(Commune commune);
        Task DeleteAsync(string id);
        Task<IEnumerable<Commune>> GetByLocationAsync(double latitude, double longitude, double radiusKm);
    }
}
