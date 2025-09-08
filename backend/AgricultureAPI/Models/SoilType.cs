using System.ComponentModel.DataAnnotations;

namespace AgricultureAPI.Models
{
    public class SoilType
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
        [MaxLength(500)]
        public string Characteristics { get; set; } = string.Empty;
        
        [Required]
        public double Ph { get; set; }
        
        [Required]
        [MaxLength(100)]
        public string Texture { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string Drainage { get; set; } = string.Empty;
        
        public virtual ICollection<Commune> Communes { get; set; } = new List<Commune>();
        public virtual ICollection<SoilTypeCrop> SoilTypeCrops { get; set; } = new List<SoilTypeCrop>();
    }
}
