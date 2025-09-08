using System.ComponentModel.DataAnnotations;

namespace AgricultureAPI.Models.Requests
{
    public class CreateUserRequest
    {
        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        [StringLength(255)]
        public string Email { get; set; } = string.Empty;

        [StringLength(20)]
        public string? PhoneNumber { get; set; }
    }
}
