using System.ComponentModel.DataAnnotations;

namespace AgricultureAPI.Models.Requests
{
    public class ProcessPaymentRequest
    {
        [Required]
        public string TransactionId { get; set; } = string.Empty;
    }
}
