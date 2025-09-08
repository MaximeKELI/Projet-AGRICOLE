using System.ComponentModel.DataAnnotations;

namespace AgricultureAPI.Models.Requests
{
    public class InitiatePaymentRequest
    {
        [Required]
        public string UserId { get; set; } = string.Empty;

        [Required]
        public string DocumentId { get; set; } = string.Empty;

        [Required]
        public string PaymentMethod { get; set; } = string.Empty;
    }
}
