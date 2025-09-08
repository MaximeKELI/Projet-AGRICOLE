using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public interface IPrefectureRepository
    {
        Task<IEnumerable<Prefecture>> GetAllAsync();
        Task<Prefecture?> GetByIdAsync(string id);
        Task<Prefecture> CreateAsync(Prefecture prefecture);
        Task<Prefecture> UpdateAsync(Prefecture prefecture);
        Task DeleteAsync(string id);
        Task<IEnumerable<Commune>> GetCommunesAsync(string prefectureId);
    }
}
