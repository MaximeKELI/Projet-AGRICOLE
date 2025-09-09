using Microsoft.AspNetCore.Mvc;
using AgricultureAPI.Services;
using AgricultureAPI.Models;

namespace AgricultureAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RegionsController : ControllerBase
    {
        private readonly IAgricultureService _agricultureService;

        public RegionsController(IAgricultureService agricultureService)
        {
            _agricultureService = agricultureService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Region>>> GetRegions()
        {
            var regions = await _agricultureService.GetRegionsAsync();
            return Ok(regions);
        }

        [HttpGet("{regionId}/prefectures")]
        public async Task<ActionResult<IEnumerable<Prefecture>>> GetPrefectures(string regionId)
        {
            var prefectures = await _agricultureService.GetPrefecturesAsync(regionId);
            return Ok(prefectures);
        }

        [HttpGet("{regionId}/communes")]
        public async Task<ActionResult<IEnumerable<Commune>>> GetCommunesByRegion(string regionId)
        {
            var communes = await _agricultureService.GetCommunesByRegionAsync(regionId);
            return Ok(communes);
        }
    }
}
