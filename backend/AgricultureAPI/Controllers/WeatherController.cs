using Microsoft.AspNetCore.Mvc;
using AgricultureAPI.Models;
using AgricultureAPI.Services;

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

        [HttpGet("current")]
        public async Task<ActionResult<WeatherData>> GetCurrentWeather([FromQuery] double lat, [FromQuery] double lon)
        {
            try
            {
                var weather = await _weatherService.GetCurrentWeatherAsync(lat, lon);
                return Ok(weather);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("forecast")]
        public async Task<ActionResult<WeatherForecast>> GetWeatherForecast([FromQuery] double lat, [FromQuery] double lon)
        {
            try
            {
                var forecast = await _weatherService.GetWeatherForecastAsync(lat, lon);
                return Ok(forecast);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("alerts")]
        public async Task<ActionResult<IEnumerable<WeatherAlert>>> GetWeatherAlerts([FromQuery] double lat, [FromQuery] double lon)
        {
            try
            {
                var alerts = await _weatherService.GetWeatherAlertsAsync(lat, lon);
                return Ok(alerts);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("agricultural")]
        public async Task<ActionResult<object>> GetAgriculturalWeatherData([FromQuery] double lat, [FromQuery] double lon)
        {
            try
            {
                var data = await _weatherService.GetAgriculturalWeatherDataAsync(lat, lon);
                return Ok(data);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("alerts")]
        public async Task<ActionResult<WeatherAlert>> CreateWeatherAlert([FromBody] WeatherAlert alert)
        {
            try
            {
                var createdAlert = await _weatherService.CreateWeatherAlertAsync(alert);
                return CreatedAtAction(nameof(GetWeatherAlerts), new { lat = 0, lon = 0 }, createdAlert);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("alerts/{id}")]
        public async Task<ActionResult<WeatherAlert>> UpdateWeatherAlert(string id, [FromBody] WeatherAlert alert)
        {
            try
            {
                if (id != alert.Id)
                    return BadRequest("ID mismatch");

                var updatedAlert = await _weatherService.UpdateWeatherAlertAsync(alert);
                return Ok(updatedAlert);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpDelete("alerts/{id}")]
        public async Task<ActionResult> DeleteWeatherAlert(string id)
        {
            try
            {
                await _weatherService.DeleteWeatherAlertAsync(id);
                return NoContent();
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
}