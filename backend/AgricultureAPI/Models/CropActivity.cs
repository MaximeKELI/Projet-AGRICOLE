using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AgricultureAPI.Models
{
    public class CropActivity
    {
        [Key]
        public string Id { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(500)]
        public string Description { get; set; } = string.Empty;
        
        [Required]
        public int DayFromPlanting { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string Category { get; set; } = string.Empty; // preparation, planting, maintenance, harvest
        
        public bool IsReminder { get; set; } = false;
        
        [Required]
        public string CropId { get; set; } = string.Empty;
        
        [ForeignKey("CropId")]
        public virtual Crop Crop { get; set; } = null!;
    }
}
