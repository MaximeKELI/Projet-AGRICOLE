using AgricultureAPI.Models;
using AgricultureAPI.Repositories;

namespace AgricultureAPI.Services
{
    public class DocumentService : IDocumentService
    {
        private readonly IDocumentRepository _documentRepository;

        public DocumentService(IDocumentRepository documentRepository)
        {
            _documentRepository = documentRepository;
        }

        public async Task<IEnumerable<DocumentRecommendation>> GetAllDocumentsAsync()
        {
            return await _documentRepository.GetAllAsync();
        }

        public async Task<DocumentRecommendation?> GetDocumentAsync(string id)
        {
            return await _documentRepository.GetByIdAsync(id);
        }

        public async Task<IEnumerable<DocumentRecommendation>> GetDocumentsByCategoryAsync(string category)
        {
            return await _documentRepository.GetByCategoryAsync(category);
        }

        public async Task<IEnumerable<DocumentRecommendation>> GetDocumentsByRegionAsync(string region)
        {
            return await _documentRepository.GetByRegionAsync(region);
        }

        public async Task<IEnumerable<DocumentRecommendation>> GetDocumentsByPrefectureAsync(string prefecture)
        {
            return await _documentRepository.GetByPrefectureAsync(prefecture);
        }

        public async Task<DocumentRecommendation> CreateDocumentAsync(DocumentRecommendation document)
        {
            return await _documentRepository.CreateAsync(document);
        }

        public async Task<DocumentRecommendation> UpdateDocumentAsync(DocumentRecommendation document)
        {
            return await _documentRepository.UpdateAsync(document);
        }

        public async Task DeleteDocumentAsync(string id)
        {
            await _documentRepository.DeleteAsync(id);
        }

        public async Task SeedDocumentsAsync()
        {
            var existingDocs = await _documentRepository.GetAllAsync();
            if (existingDocs.Any())
            {
                // Mettre à jour les prix existants
                foreach (var doc in existingDocs)
                {
                    switch (doc.Id)
                    {
                        case "doc_tchamba":
                            doc.Price = 5000;
                            break;
                        case "doc_blitta":
                            doc.Price = 3500;
                            break;
                        case "doc_mo":
                            doc.Price = 4000;
                            break;
                    }
                    await _documentRepository.UpdateAsync(doc);
                }
                return;
            }

            var documents = new List<DocumentRecommendation>
            {
                new DocumentRecommendation
                {
                    Id = "doc_tchamba",
                    Title = "Recommandations de cultures - Fiches Tchamba",
                    Description = "Guide complet des recommandations de cultures pour la région de Tchamba avec techniques agricoles adaptées au climat local.",
                    FilePath = "lib/Fiche_de_documentation/Recommendation de cultures de fiches-tchamba.pdf",
                    Price = 5000, // 5000 FCFA - Prix réaliste pour document technique complet
                    Category = "culture",
                    Prefecture = "Tchamba",
                    Region = "Centrale",
                    FileSizeBytes = 1269916,
                    FileExtension = ".pdf",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    IsActive = true
                },
                new DocumentRecommendation
                {
                    Id = "doc_blitta",
                    Title = "Guide agricole - Blitta",
                    Description = "Documentation technique pour l'agriculture dans la région de Blitta, incluant les meilleures pratiques et calendriers de plantation.",
                    FilePath = "lib/Fiche_de_documentation/blitta.pdf",
                    Price = 3500, // 3500 FCFA - Prix réaliste pour guide technique
                    Category = "technique",
                    Prefecture = "Blitta",
                    Region = "Centrale",
                    FileSizeBytes = 1278932,
                    FileExtension = ".pdf",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    IsActive = true
                },
                new DocumentRecommendation
                {
                    Id = "doc_mo",
                    Title = "Recommandations de culture - Préfecture de Mô",
                    Description = "Fiche technique détaillée pour les cultures adaptées à la préfecture de Mô avec conseils pratiques et recommandations saisonnières.",
                    FilePath = "lib/Fiche_de_documentation/recommendation de culture de la prefecture de mo.pdf",
                    Price = 4000, // 4000 FCFA - Prix réaliste pour fiche technique détaillée
                    Category = "culture",
                    Prefecture = "Mô",
                    Region = "Plateaux",
                    FileSizeBytes = 1255455,
                    FileExtension = ".pdf",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    IsActive = true
                }
            };

            foreach (var document in documents)
            {
                await _documentRepository.CreateAsync(document);
            }
        }
    }
}
