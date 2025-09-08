using System.ComponentModel.DataAnnotations;

namespace AgricultureAPI.Models
{
    public class WeatherAlert
    {
        [Key]
        public string Id { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(50)]
        public string Type { get; set; } = string.Empty; // rain, drought, temperature, wind
        
        [Required]
        [MaxLength(20)]
        public string Severity { get; set; } = string.Empty; // low, medium, high
        
        [Required]
        [MaxLength(500)]
        public string Message { get; set; } = string.Empty;
        
        [Required]
        public DateTime StartDate { get; set; }
        
        public DateTime? EndDate { get; set; }
        
        [Required]
        [MaxLength(1000)]
        public string Recommendations { get; set; } = string.Empty;
    }
}
