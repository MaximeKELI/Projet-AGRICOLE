using Microsoft.AspNetCore.Mvc;
using AgricultureAPI.Models;
using AgricultureAPI.Models.Requests;
using AgricultureAPI.Services;

namespace AgricultureAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentsController : ControllerBase
    {
        private readonly IPaymentService _paymentService;

        public PaymentsController(IPaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        [HttpPost("initiate")]
        public async Task<ActionResult<Payment>> InitiatePayment([FromBody] InitiatePaymentRequest request)
        {
            try
            {
                var payment = await _paymentService.InitiatePaymentAsync(
                    request.UserId, 
                    request.DocumentId, 
                    request.PaymentMethod);
                
                return Ok(payment);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("{paymentId}/process")]
        public async Task<ActionResult<Payment>> ProcessPayment(string paymentId, [FromBody] ProcessPaymentRequest request)
        {
            try
            {
                var payment = await _paymentService.ProcessPaymentAsync(paymentId, request.TransactionId);
                return Ok(payment);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("{paymentId}/complete")]
        public async Task<ActionResult<Payment>> CompletePayment(string paymentId)
        {
            try
            {
                var payment = await _paymentService.CompletePaymentAsync(paymentId);
                return Ok(payment);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("{paymentId}/fail")]
        public async Task<ActionResult<Payment>> FailPayment(string paymentId, [FromBody] FailPaymentRequest request)
        {
            try
            {
                var payment = await _paymentService.FailPaymentAsync(paymentId, request.Reason);
                return Ok(payment);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("verify/{transactionId}")]
        public async Task<ActionResult<bool>> VerifyPayment(string transactionId)
        {
            var isValid = await _paymentService.VerifyPaymentAsync(transactionId);
            return Ok(new { IsValid = isValid });
        }

        [HttpGet("access/{userId}/{documentId}")]
        public async Task<ActionResult<bool>> CheckAccess(string userId, string documentId)
        {
            var hasAccess = await _paymentService.HasAccessToDocumentAsync(userId, documentId);
            return Ok(new { HasAccess = hasAccess });
        }

        [HttpPost("simulate-mobile-money")]
        public async Task<ActionResult> SimulateMobileMoneyPayment([FromBody] MobileMoneySimulationRequest request)
        {
            // Simulation d'un paiement mobile money (MTN, Moov, etc.)
            try
            {
                // Étape 1: Traiter le paiement
                var payment = await _paymentService.ProcessPaymentAsync(request.PaymentId, request.PhoneNumber);
                
                // Étape 2: Simuler la validation (en production, ceci viendrait de l'opérateur)
                var isValid = await _paymentService.VerifyPaymentAsync(request.PhoneNumber);
                
                if (isValid)
                {
                    // Étape 3: Compléter le paiement
                    await _paymentService.CompletePaymentAsync(request.PaymentId);
                    return Ok(new { Success = true, Message = "Paiement mobile money réussi" });
                }
                else
                {
                    await _paymentService.FailPaymentAsync(request.PaymentId, "Échec de la validation mobile money");
                    return BadRequest(new { Success = false, Message = "Échec du paiement mobile money" });
                }
            }
            catch (Exception ex)
            {
                return BadRequest(new { Success = false, Message = ex.Message });
            }
        }
    }

    public class InitiatePaymentRequest
    {
        public string UserId { get; set; } = string.Empty;
        public string DocumentId { get; set; } = string.Empty;
        public string PaymentMethod { get; set; } = string.Empty;
    }

    public class ProcessPaymentRequest
    {
        public string TransactionId { get; set; } = string.Empty;
    }

    public class FailPaymentRequest
    {
        public string Reason { get; set; } = string.Empty;
    }

    public class MobileMoneySimulationRequest
    {
        public string PaymentId { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string Operator { get; set; } = string.Empty; // MTN, Moov, etc.
    }
}
