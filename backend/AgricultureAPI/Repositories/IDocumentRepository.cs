using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public interface IDocumentRepository
    {
        Task<IEnumerable<DocumentRecommendation>> GetAllAsync();
        Task<DocumentRecommendation?> GetByIdAsync(string id);
        Task<DocumentRecommendation> CreateAsync(DocumentRecommendation document);
        Task<DocumentRecommendation> UpdateAsync(DocumentRecommendation document);
        Task DeleteAsync(string id);
        Task<IEnumerable<DocumentRecommendation>> GetByCategoryAsync(string category);
        Task<IEnumerable<DocumentRecommendation>> GetByRegionAsync(string region);
        Task<IEnumerable<DocumentRecommendation>> GetByPrefectureAsync(string prefecture);
        Task<bool> HasUserPurchasedAsync(string userId, string documentId);
    }
}
