using System.ComponentModel.DataAnnotations;

namespace AgricultureAPI.Models
{
    public class DocumentRecommendation
    {
        [Key]
        public string Id { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(1000)]
        public string Description { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(500)]
        public string FilePath { get; set; } = string.Empty;
        
        [Required]
        public decimal Price { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string Category { get; set; } = string.Empty; // culture, sol, technique, etc.
        
        [MaxLength(100)]
        public string Prefecture { get; set; } = string.Empty;
        
        [MaxLength(100)]
        public string Region { get; set; } = string.Empty;
        
        public long FileSizeBytes { get; set; }
        
        [MaxLength(10)]
        public string FileExtension { get; set; } = string.Empty;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
        
        public bool IsActive { get; set; } = true;
        
        public virtual ICollection<UserPurchase> Purchases { get; set; } = new List<UserPurchase>();
    }
}
