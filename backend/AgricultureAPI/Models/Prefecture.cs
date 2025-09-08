using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AgricultureAPI.Models
{
    public class Prefecture
    {
        [Key]
        public string Id { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [Required]
        public string RegionId { get; set; } = string.Empty;
        
        [ForeignKey("RegionId")]
        public virtual Region Region { get; set; } = null!;
        
        public virtual ICollection<Commune> Communes { get; set; } = new List<Commune>();
    }
}
