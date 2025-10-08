using Microsoft.AspNetCore.Mvc;
using AgricultureAPI.Models;
using AgricultureAPI.Services;

namespace AgricultureAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AgriculturalMetricsController : ControllerBase
    {
        private readonly IAgriculturalMetricsService _metricsService;

        public AgriculturalMetricsController(IAgriculturalMetricsService metricsService)
        {
            _metricsService = metricsService;
        }

        [HttpGet("user/{userId}")]
        public async Task<ActionResult<IEnumerable<AgriculturalMetrics>>> GetUserMetrics(string userId)
        {
            try
            {
                var metrics = await _metricsService.GetUserMetricsAsync(userId);
                return Ok(metrics);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<AgriculturalMetrics>> GetMetric(string id)
        {
            try
            {
                var metric = await _metricsService.GetMetricAsync(id);
                if (metric == null)
                    return NotFound();
                return Ok(metric);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost]
        public async Task<ActionResult<AgriculturalMetrics>> CreateMetric([FromBody] AgriculturalMetrics metric)
        {
            try
            {
                var createdMetric = await _metricsService.CreateMetricAsync(metric);
                return CreatedAtAction(nameof(GetMetric), new { id = createdMetric.Id }, createdMetric);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<AgriculturalMetrics>> UpdateMetric(string id, [FromBody] AgriculturalMetrics metric)
        {
            try
            {
                if (id != metric.Id)
                    return BadRequest("ID mismatch");

                var updatedMetric = await _metricsService.UpdateMetricAsync(metric);
                return Ok(updatedMetric);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> DeleteMetric(string id)
        {
            try
            {
                await _metricsService.DeleteMetricAsync(id);
                return NoContent();
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("dashboard/{userId}")]
        public async Task<ActionResult<DashboardSummary>> GetDashboardSummary(string userId)
        {
            try
            {
                var summary = await _metricsService.GetDashboardSummaryAsync(userId);
                return Ok(summary);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("predictions")]
        public async Task<ActionResult<object>> GetYieldPredictions([FromQuery] string cropType, [FromQuery] string region)
        {
            try
            {
                var predictions = await _metricsService.GetYieldPredictionsAsync(cropType, region);
                return Ok(predictions);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("alerts/{userId}")]
        public async Task<ActionResult<IEnumerable<object>>> GetAgriculturalAlerts(string userId)
        {
            try
            {
                var alerts = await _metricsService.GetAgriculturalAlertsAsync(userId);
                return Ok(alerts);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
}
