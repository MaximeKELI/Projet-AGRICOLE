using AgricultureAPI.Models;

namespace AgricultureAPI.Services
{
    public interface IDocumentService
    {
        Task<IEnumerable<DocumentRecommendation>> GetAllDocumentsAsync();
        Task<DocumentRecommendation?> GetDocumentAsync(string id);
        Task<IEnumerable<DocumentRecommendation>> GetDocumentsByCategoryAsync(string category);
        Task<IEnumerable<DocumentRecommendation>> GetDocumentsByRegionAsync(string region);
        Task<IEnumerable<DocumentRecommendation>> GetDocumentsByPrefectureAsync(string prefecture);
        Task<DocumentRecommendation> CreateDocumentAsync(DocumentRecommendation document);
        Task<DocumentRecommendation> UpdateDocumentAsync(DocumentRecommendation document);
        Task DeleteDocumentAsync(string id);
        Task SeedDocumentsAsync();
    }
}
