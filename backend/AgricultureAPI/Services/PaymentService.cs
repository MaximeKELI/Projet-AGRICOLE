using AgricultureAPI.Models;
using AgricultureAPI.Repositories;
using System.Text.Json;

namespace AgricultureAPI.Services
{
    public class PaymentService : IPaymentService
    {
        private readonly IPaymentRepository _paymentRepository;
        private readonly IUserRepository _userRepository;
        private readonly IDocumentRepository _documentRepository;

        public PaymentService(
            IPaymentRepository paymentRepository,
            IUserRepository userRepository,
            IDocumentRepository documentRepository)
        {
            _paymentRepository = paymentRepository;
            _userRepository = userRepository;
            _documentRepository = documentRepository;
        }

        public async Task<Payment> InitiatePaymentAsync(string userId, string documentId, string paymentMethod)
        {
            var document = await _documentRepository.GetByIdAsync(documentId);
            if (document == null)
                throw new ArgumentException("Document non trouvé");

            var payment = new Payment
            {
                Id = Guid.NewGuid().ToString(),
                UserId = userId,
                DocumentId = documentId,
                Amount = document.Price,
                Currency = "XOF",
                PaymentMethod = paymentMethod,
                Status = "pending",
                CreatedAt = DateTime.UtcNow,
                PaymentDetails = JsonSerializer.Serialize(new
                {
                    DocumentTitle = document.Title,
                    PaymentMethod = paymentMethod,
                    InitiatedAt = DateTime.UtcNow
                })
            };

            return await _paymentRepository.CreateAsync(payment);
        }

        public async Task<Payment> ProcessPaymentAsync(string paymentId, string transactionId)
        {
            var payment = await _paymentRepository.GetByIdAsync(paymentId);
            if (payment == null)
                throw new ArgumentException("Paiement non trouvé");

            payment.TransactionId = transactionId;
            payment.Status = "processing";

            return await _paymentRepository.UpdateAsync(payment);
        }

        public async Task<Payment> CompletePaymentAsync(string paymentId)
        {
            var payment = await _paymentRepository.GetByIdAsync(paymentId);
            if (payment == null)
                throw new ArgumentException("Paiement non trouvé");

            payment.Status = "completed";
            payment.CompletedAt = DateTime.UtcNow;

            var updatedPayment = await _paymentRepository.UpdateAsync(payment);

            // Accorder l'accès au document
            await GrantDocumentAccessAsync(payment.UserId, payment.DocumentId, paymentId);

            return updatedPayment;
        }

        public async Task<Payment> FailPaymentAsync(string paymentId, string reason)
        {
            var payment = await _paymentRepository.GetByIdAsync(paymentId);
            if (payment == null)
                throw new ArgumentException("Paiement non trouvé");

            payment.Status = "failed";
            payment.Notes = reason;

            return await _paymentRepository.UpdateAsync(payment);
        }

        public async Task<bool> VerifyPaymentAsync(string transactionId)
        {
            // Simulation de vérification avec un processeur de paiement
            // En production, ceci ferait appel à l'API du processeur (Stripe, PayPal, etc.)
            
            // Pour la simulation, on considère que tous les paiements sont valides
            // sauf ceux qui contiennent "FAIL" dans l'ID
            return !transactionId.Contains("FAIL", StringComparison.OrdinalIgnoreCase);
        }

        public async Task<UserPurchase> GrantDocumentAccessAsync(string userId, string documentId, string paymentId)
        {
            var existingPurchase = await _userRepository.GetPurchaseAsync(userId, documentId);
            if (existingPurchase != null)
                return existingPurchase;

            var document = await _documentRepository.GetByIdAsync(documentId);
            if (document == null)
                throw new ArgumentException("Document non trouvé");

            var purchase = new UserPurchase
            {
                UserId = userId,
                DocumentId = documentId,
                PaymentId = paymentId,
                PricePaid = document.Price,
                PurchaseDate = DateTime.UtcNow,
                AccessExpiryDate = DateTime.UtcNow.AddYears(1), // Accès valide 1 an
                IsActive = true,
                DownloadCount = 0,
                MaxDownloads = 5
            };

            return await _userRepository.CreatePurchaseAsync(purchase);
        }

        public async Task<bool> HasAccessToDocumentAsync(string userId, string documentId)
        {
            var purchase = await _userRepository.GetPurchaseAsync(userId, documentId);
            
            if (purchase == null || !purchase.IsActive)
                return false;

            // Vérifier si l'accès n'a pas expiré
            if (purchase.AccessExpiryDate.HasValue && purchase.AccessExpiryDate < DateTime.UtcNow)
                return false;

            return true;
        }

        public async Task<byte[]> GetDocumentContentAsync(string userId, string documentId)
        {
            if (!await HasAccessToDocumentAsync(userId, documentId))
                throw new UnauthorizedAccessException("Accès non autorisé au document");

            var document = await _documentRepository.GetByIdAsync(documentId);
            if (document == null)
                throw new ArgumentException("Document non trouvé");

            var purchase = await _userRepository.GetPurchaseAsync(userId, documentId);
            if (purchase != null)
            {
                // Vérifier la limite de téléchargements
                if (purchase.DownloadCount >= purchase.MaxDownloads)
                    throw new InvalidOperationException("Limite de téléchargements atteinte");

                // Incrémenter le compteur de téléchargements
                purchase.DownloadCount++;
                await _userRepository.UpdatePurchaseAsync(purchase);
            }

            // Lire le fichier depuis le système de fichiers
            var fullPath = Path.Combine(Directory.GetCurrentDirectory(), document.FilePath);
            if (!File.Exists(fullPath))
                throw new FileNotFoundException("Fichier non trouvé sur le serveur");

            return await File.ReadAllBytesAsync(fullPath);
        }
    }
}
