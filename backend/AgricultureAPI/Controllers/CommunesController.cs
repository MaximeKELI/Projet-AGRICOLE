using Microsoft.AspNetCore.Mvc;
using AgricultureAPI.Services;
using AgricultureAPI.Models;

namespace AgricultureAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CommunesController : ControllerBase
    {
        private readonly IAgricultureService _agricultureService;

        public CommunesController(IAgricultureService agricultureService)
        {
            _agricultureService = agricultureService;
        }

        [HttpGet("{communeId}/soil-type")]
        public async Task<ActionResult<SoilType>> GetSoilType(string communeId)
        {
            var soilType = await _agricultureService.GetSoilTypeForCommuneAsync(communeId);
            if (soilType == null)
                return NotFound();
            
            return Ok(soilType);
        }

        [HttpGet("nearby")]
        public async Task<ActionResult<IEnumerable<Commune>>> GetNearbyCommunes(
            [FromQuery] double latitude, 
            [FromQuery] double longitude, 
            [FromQuery] double radiusKm = 50)
        {
            var communes = await _agricultureService.GetCommunesByLocationAsync(latitude, longitude, radiusKm);
            return Ok(communes);
        }
    }
}
