using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AgricultureAPI.Models
{
    public class UserPurchase
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        public string UserId { get; set; } = string.Empty;
        
        [ForeignKey("UserId")]
        public virtual User User { get; set; } = null!;
        
        [Required]
        public string DocumentId { get; set; } = string.Empty;
        
        [ForeignKey("DocumentId")]
        public virtual DocumentRecommendation Document { get; set; } = null!;
        
        [Required]
        public string PaymentId { get; set; } = string.Empty;
        
        [Required]
        public decimal PricePaid { get; set; }
        
        public DateTime PurchaseDate { get; set; } = DateTime.UtcNow;
        
        public DateTime? AccessExpiryDate { get; set; } // Pour un accès limité dans le temps
        
        public bool IsActive { get; set; } = true;
        
        public int DownloadCount { get; set; } = 0;
        
        public int MaxDownloads { get; set; } = 5; // Limite de téléchargements
    }
}
