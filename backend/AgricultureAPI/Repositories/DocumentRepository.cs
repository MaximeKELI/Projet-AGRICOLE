using Microsoft.EntityFrameworkCore;
using AgricultureAPI.Data;
using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public class DocumentRepository : IDocumentRepository
    {
        private readonly AgricultureDbContext _context;

        public DocumentRepository(AgricultureDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<DocumentRecommendation>> GetAllAsync()
        {
            return await _context.DocumentRecommendations
                .Where(d => d.IsActive)
                .OrderBy(d => d.Title)
                .ToListAsync();
        }

        public async Task<DocumentRecommendation?> GetByIdAsync(string id)
        {
            return await _context.DocumentRecommendations
                .FirstOrDefaultAsync(d => d.Id == id && d.IsActive);
        }

        public async Task<DocumentRecommendation> CreateAsync(DocumentRecommendation document)
        {
            _context.DocumentRecommendations.Add(document);
            await _context.SaveChangesAsync();
            return document;
        }

        public async Task<DocumentRecommendation> UpdateAsync(DocumentRecommendation document)
        {
            document.UpdatedAt = DateTime.UtcNow;
            _context.Entry(document).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return document;
        }

        public async Task DeleteAsync(string id)
        {
            var document = await _context.DocumentRecommendations.FindAsync(id);
            if (document != null)
            {
                document.IsActive = false;
                await _context.SaveChangesAsync();
            }
        }

        public async Task<IEnumerable<DocumentRecommendation>> GetByCategoryAsync(string category)
        {
            return await _context.DocumentRecommendations
                .Where(d => d.Category == category && d.IsActive)
                .OrderBy(d => d.Title)
                .ToListAsync();
        }

        public async Task<IEnumerable<DocumentRecommendation>> GetByRegionAsync(string region)
        {
            return await _context.DocumentRecommendations
                .Where(d => d.Region == region && d.IsActive)
                .OrderBy(d => d.Title)
                .ToListAsync();
        }

        public async Task<IEnumerable<DocumentRecommendation>> GetByPrefectureAsync(string prefecture)
        {
            return await _context.DocumentRecommendations
                .Where(d => d.Prefecture == prefecture && d.IsActive)
                .OrderBy(d => d.Title)
                .ToListAsync();
        }

        public async Task<bool> HasUserPurchasedAsync(string userId, string documentId)
        {
            return await _context.UserPurchases
                .AnyAsync(up => up.UserId == userId && 
                               up.DocumentId == documentId && 
                               up.IsActive);
        }
    }
}
