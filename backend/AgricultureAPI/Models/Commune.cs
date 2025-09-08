using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AgricultureAPI.Models
{
    public class Commune
    {
        [Key]
        public string Id { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [Required]
        public string PrefectureId { get; set; } = string.Empty;
        
        [ForeignKey("PrefectureId")]
        public virtual Prefecture Prefecture { get; set; } = null!;
        
        [Required]
        public string SoilTypeId { get; set; } = string.Empty;
        
        [ForeignKey("SoilTypeId")]
        public virtual SoilType SoilType { get; set; } = null!;
        
        [Required]
        public double Latitude { get; set; }
        
        [Required]
        public double Longitude { get; set; }
    }
}
