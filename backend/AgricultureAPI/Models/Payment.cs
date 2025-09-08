using System.ComponentModel.DataAnnotations;

namespace AgricultureAPI.Models
{
    public class Payment
    {
        [Key]
        public string Id { get; set; } = string.Empty;
        
        [Required]
        public string UserId { get; set; } = string.Empty;
        
        [Required]
        public string DocumentId { get; set; } = string.Empty;
        
        [Required]
        public decimal Amount { get; set; }
        
        [Required]
        [MaxLength(10)]
        public string Currency { get; set; } = "XOF"; // Franc CFA
        
        [Required]
        [MaxLength(50)]
        public string PaymentMethod { get; set; } = string.Empty; // mobile_money, card, etc.
        
        [Required]
        [MaxLength(50)]
        public string Status { get; set; } = string.Empty; // pending, completed, failed, refunded
        
        [MaxLength(200)]
        public string TransactionId { get; set; } = string.Empty; // ID du processeur de paiement
        
        [MaxLength(500)]
        public string PaymentDetails { get; set; } = string.Empty; // JSON avec détails du paiement
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? CompletedAt { get; set; }
        
        [MaxLength(1000)]
        public string Notes { get; set; } = string.Empty;
    }
}
