using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AgricultureAPI.Models
{
    public class SoilTypeCrop
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        public string SoilTypeId { get; set; } = string.Empty;
        
        [ForeignKey("SoilTypeId")]
        public virtual SoilType SoilType { get; set; } = null!;
        
        [Required]
        public string CropId { get; set; } = string.Empty;
        
        [ForeignKey("CropId")]
        public virtual Crop Crop { get; set; } = null!;
    }
}
