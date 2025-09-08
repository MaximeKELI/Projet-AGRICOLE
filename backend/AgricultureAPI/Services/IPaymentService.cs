using AgricultureAPI.Models;

namespace AgricultureAPI.Services
{
    public interface IPaymentService
    {
        Task<Payment> InitiatePaymentAsync(string userId, string documentId, string paymentMethod);
        Task<Payment> ProcessPaymentAsync(string paymentId, string transactionId);
        Task<Payment> CompletePaymentAsync(string paymentId);
        Task<Payment> FailPaymentAsync(string paymentId, string reason);
        Task<bool> VerifyPaymentAsync(string transactionId);
        Task<UserPurchase> GrantDocumentAccessAsync(string userId, string documentId, string paymentId);
        Task<bool> HasAccessToDocumentAsync(string userId, string documentId);
        Task<byte[]> GetDocumentContentAsync(string userId, string documentId);
    }
}
