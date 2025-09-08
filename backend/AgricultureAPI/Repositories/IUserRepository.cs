using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public interface IUserRepository
    {
        Task<User> CreateAsync(User user);
        Task<User?> GetByIdAsync(string id);
        Task<User?> GetByEmailAsync(string email);
        Task<User> UpdateAsync(User user);
        Task<IEnumerable<UserPurchase>> GetUserPurchasesAsync(string userId);
        Task<UserPurchase> CreatePurchaseAsync(UserPurchase purchase);
        Task<UserPurchase?> GetPurchaseAsync(string userId, string documentId);
        Task<UserPurchase> UpdatePurchaseAsync(UserPurchase purchase);
    }
}
