using Microsoft.AspNetCore.Mvc;
using AgricultureAPI.Services;
using AgricultureAPI.Models;

namespace AgricultureAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DocumentsController : ControllerBase
    {
        private readonly IDocumentService _documentService;
        private readonly IPaymentService _paymentService;

        public DocumentsController(IDocumentService documentService, IPaymentService paymentService)
        {
            _documentService = documentService;
            _paymentService = paymentService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<DocumentRecommendation>>> GetDocuments()
        {
            var documents = await _documentService.GetAllDocumentsAsync();
            return Ok(documents);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<DocumentRecommendation>> GetDocument(string id)
        {
            var document = await _documentService.GetDocumentAsync(id);
            if (document == null)
                return NotFound();
            
            return Ok(document);
        }

        [HttpGet("category/{category}")]
        public async Task<ActionResult<IEnumerable<DocumentRecommendation>>> GetDocumentsByCategory(string category)
        {
            var documents = await _documentService.GetDocumentsByCategoryAsync(category);
            return Ok(documents);
        }

        [HttpGet("region/{region}")]
        public async Task<ActionResult<IEnumerable<DocumentRecommendation>>> GetDocumentsByRegion(string region)
        {
            var documents = await _documentService.GetDocumentsByRegionAsync(region);
            return Ok(documents);
        }

        [HttpGet("prefecture/{prefecture}")]
        public async Task<ActionResult<IEnumerable<DocumentRecommendation>>> GetDocumentsByPrefecture(string prefecture)
        {
            var documents = await _documentService.GetDocumentsByPrefectureAsync(prefecture);
            return Ok(documents);
        }

        [HttpGet("{id}/download")]
        public async Task<IActionResult> DownloadDocument(string id, [FromQuery] string userId)
        {
            try
            {
                // Vérifier si c'est le document gratuit de la préfecture de Mô
                if (id == "doc_mo")
                {
                    // Accès gratuit pour le document de Mô
                    var document = await _documentService.GetDocumentAsync(id);
                    if (document != null)
                    {
                        // Construire le chemin absolu vers le fichier PDF
                        var projectRoot = Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), "..", ".."));
                        var absolutePath = Path.Combine(projectRoot, document.FilePath);
                        
                        if (System.IO.File.Exists(absolutePath))
                        {
                            var fileBytes = await System.IO.File.ReadAllBytesAsync(absolutePath);
                            return File(fileBytes, "application/pdf", $"{document.Title}.pdf");
                        }
                    }
                    return NotFound("Document non trouvé");
                }

                // Pour les autres documents, vérifier l'accès payant
                var hasAccess = await _paymentService.HasAccessToDocumentAsync(userId, id);
                if (!hasAccess)
                {
                    return Unauthorized("Accès non autorisé à ce document");
                }

                var content = await _paymentService.GetDocumentContentAsync(userId, id);
                if (content == null)
                {
                    return NotFound("Document non trouvé");
                }

                return File(content, "application/pdf", $"{id}.pdf");
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (FileNotFoundException)
            {
                return NotFound("Fichier non disponible");
            }
        }

        [HttpPost]
        public async Task<ActionResult<DocumentRecommendation>> CreateDocument([FromBody] DocumentRecommendation document)
        {
            document.Id = Guid.NewGuid().ToString();
            var createdDocument = await _documentService.CreateDocumentAsync(document);
            return CreatedAtAction(nameof(GetDocument), new { id = createdDocument.Id }, createdDocument);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<DocumentRecommendation>> UpdateDocument(string id, [FromBody] DocumentRecommendation document)
        {
            document.Id = id;
            var updatedDocument = await _documentService.UpdateDocumentAsync(document);
            return Ok(updatedDocument);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteDocument(string id)
        {
            await _documentService.DeleteDocumentAsync(id);
            return NoContent();
        }
    }
}
