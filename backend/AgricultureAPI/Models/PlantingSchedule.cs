using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AgricultureAPI.Models
{
    public class PlantingSchedule
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        public string CropId { get; set; } = string.Empty;
        
        [ForeignKey("CropId")]
        public virtual Crop Crop { get; set; } = null!;
        
        [Required]
        public DateTime OptimalStartDate { get; set; }
        
        [Required]
        public DateTime OptimalEndDate { get; set; }
        
        [Required]
        [MaxLength(500)]
        public string ClimateConsiderations { get; set; } = string.Empty;
    }
}
