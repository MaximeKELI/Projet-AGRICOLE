using System.ComponentModel.DataAnnotations;

namespace AgricultureAPI.Models
{
    public class Crop
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
        public int GrowthDurationDays { get; set; }
        
        [Required]
        [MaxLength(100)]
        public string PlantingSeason { get; set; } = string.Empty;
        
        public virtual ICollection<SoilTypeCrop> SoilTypeCrops { get; set; } = new List<SoilTypeCrop>();
        public virtual ICollection<CropActivity> Activities { get; set; } = new List<CropActivity>();
        public virtual PlantingSchedule? PlantingSchedule { get; set; }
    }
}
