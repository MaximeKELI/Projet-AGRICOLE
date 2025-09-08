using System.ComponentModel.DataAnnotations;

namespace AgricultureAPI.Models
{
    public class Region
    {
        [Key]
        public string Id { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        public virtual ICollection<Prefecture> Prefectures { get; set; } = new List<Prefecture>();
    }
}
