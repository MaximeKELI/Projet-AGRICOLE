using Microsoft.AspNetCore.Mvc;
using AgricultureAPI.Services;
using AgricultureAPI.Models;

namespace AgricultureAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class WeatherController : ControllerBase
    {
        private readonly IWeatherService _weatherService;

        public WeatherController(IWeatherService weatherService)
        {
            _weatherService = weatherService;
        }

        [HttpGet("alerts")]
        public async Task<ActionResult<IEnumerable<WeatherAlert>>> GetCurrentAlerts()
        {
            var alerts = await _weatherService.GetCurrentWeatherAlertsAsync();
            return Ok(alerts);
        }

        [HttpGet("alerts/{type}")]
        public async Task<ActionResult<IEnumerable<WeatherAlert>>> GetAlertsByType(string type)
        {
            var alerts = await _weatherService.GetAlertsByTypeAsync(type);
            return Ok(alerts);
        }

        [HttpPost("alerts")]
        public async Task<ActionResult<WeatherAlert>> CreateAlert([FromBody] WeatherAlert weatherAlert)
        {
            var createdAlert = await _weatherService.CreateWeatherAlertAsync(weatherAlert);
            return CreatedAtAction(nameof(GetAlertsByType), new { type = createdAlert.Type }, createdAlert);
        }

        [HttpPut("alerts/{id}")]
        public async Task<ActionResult<WeatherAlert>> UpdateAlert(string id, [FromBody] WeatherAlert weatherAlert)
        {
            weatherAlert.Id = id;
            var updatedAlert = await _weatherService.UpdateWeatherAlertAsync(weatherAlert);
            return Ok(updatedAlert);
        }

        [HttpDelete("alerts/{id}")]
        public async Task<IActionResult> DeleteAlert(string id)
        {
            await _weatherService.DeleteWeatherAlertAsync(id);
            return NoContent();
        }
    }
}
