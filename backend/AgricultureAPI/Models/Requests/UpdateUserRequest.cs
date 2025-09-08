using System.ComponentModel.DataAnnotations;

namespace AgricultureAPI.Models.Requests
{
    public class UpdateUserRequest
    {
        [StringLength(100)]
        public string? Name { get; set; }

        [EmailAddress]
        [StringLength(255)]
        public string? Email { get; set; }

        [StringLength(20)]
        public string? PhoneNumber { get; set; }
    }
}
