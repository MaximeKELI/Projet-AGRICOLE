using Microsoft.EntityFrameworkCore;
using AgricultureAPI.Data;
using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly AgricultureDbContext _context;

        public UserRepository(AgricultureDbContext context)
        {
            _context = context;
        }

        public async Task<User> CreateAsync(User user)
        {
            _context.Users.Add(user);
            await _context.SaveChangesAsync();
            return user;
        }

        public async Task<User?> GetByIdAsync(string id)
        {
            return await _context.Users
                .Include(u => u.Purchases)
                .ThenInclude(p => p.Document)
                .FirstOrDefaultAsync(u => u.Id == id);
        }

        public async Task<User?> GetByEmailAsync(string email)
        {
            return await _context.Users
                .Include(u => u.Purchases)
                .ThenInclude(p => p.Document)
                .FirstOrDefaultAsync(u => u.Email == email);
        }

        public async Task<User> UpdateAsync(User user)
        {
            _context.Entry(user).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return user;
        }

        public async Task<IEnumerable<UserPurchase>> GetUserPurchasesAsync(string userId)
        {
            return await _context.UserPurchases
                .Include(up => up.Document)
                .Where(up => up.UserId == userId && up.IsActive)
                .OrderByDescending(up => up.PurchaseDate)
                .ToListAsync();
        }

        public async Task<UserPurchase> CreatePurchaseAsync(UserPurchase purchase)
        {
            _context.UserPurchases.Add(purchase);
            await _context.SaveChangesAsync();
            return purchase;
        }

        public async Task<UserPurchase?> GetPurchaseAsync(string userId, string documentId)
        {
            return await _context.UserPurchases
                .Include(up => up.Document)
                .FirstOrDefaultAsync(up => up.UserId == userId && 
                                          up.DocumentId == documentId && 
                                          up.IsActive);
        }

        public async Task<UserPurchase> UpdatePurchaseAsync(UserPurchase purchase)
        {
            _context.Entry(purchase).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return purchase;
        }
    }
}
