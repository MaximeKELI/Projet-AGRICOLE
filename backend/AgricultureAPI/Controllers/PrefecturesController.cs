using Microsoft.AspNetCore.Mvc;
using AgricultureAPI.Services;
using AgricultureAPI.Models;

namespace AgricultureAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PrefecturesController : ControllerBase
    {
        private readonly IAgricultureService _agricultureService;

        public PrefecturesController(IAgricultureService agricultureService)
        {
            _agricultureService = agricultureService;
        }

        [HttpGet("{prefectureId}/communes")]
        public async Task<ActionResult<IEnumerable<Commune>>> GetCommunes(string prefectureId)
        {
            var communes = await _agricultureService.GetCommunesAsync(prefectureId);
            return Ok(communes);
        }
    }
}
