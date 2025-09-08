using AgricultureAPI.Models;

namespace AgricultureAPI.Repositories
{
    public interface IPaymentRepository
    {
        Task<Payment> CreateAsync(Payment payment);
        Task<Payment?> GetByIdAsync(string id);
        Task<Payment> UpdateAsync(Payment payment);
        Task<IEnumerable<Payment>> GetByUserIdAsync(string userId);
        Task<IEnumerable<Payment>> GetByStatusAsync(string status);
        Task<Payment?> GetByTransactionIdAsync(string transactionId);
    }
}
