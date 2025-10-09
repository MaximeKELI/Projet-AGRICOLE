using Microsoft.AspNetCore.Mvc;
using AgricultureAPI.Services;
using AgricultureAPI.Models;

namespace AgricultureAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CropsController : ControllerBase
    {
        private readonly IAgricultureService _agricultureService;

        public CropsController(IAgricultureService agricultureService)
        {
            _agricultureService = agricultureService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Crop>>> GetCrops()
        {
            var crops = await _agricultureService.GetCropsAsync();
            return Ok(crops);
        }

        [HttpGet("{cropId}")]
        public async Task<ActionResult<Crop>> GetCrop(string cropId)
        {
            var crop = await _agricultureService.GetCropAsync(cropId);
            if (crop == null)
                return NotFound();
            
            return Ok(crop);
        }

        [HttpGet("recommended/{soilTypeId}")]
        public async Task<ActionResult<IEnumerable<Crop>>> GetRecommendedCrops(string soilTypeId)
        {
            var crops = await _agricultureService.GetRecommendedCropsAsync(soilTypeId);
            return Ok(crops);
        }

        [HttpGet("{cropId}/activities/upcoming")]
        public async Task<ActionResult<IEnumerable<CropActivity>>> GetUpcomingActivities(
            string cropId, 
            [FromQuery] DateTime plantingDate)
        {
            var activities = await _agricultureService.GetUpcomingActivitiesAsync(cropId, plantingDate);
            return Ok(activities);
        }
    }
}
