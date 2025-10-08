using System.ComponentModel.DataAnnotations;

namespace AgricultureAPI.Models
{
    public class AgriculturalMetrics
    {
        [Key]
        public string Id { get; set; } = string.Empty;
        
        [Required]
        public string UserId { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string CropType { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string Region { get; set; } = string.Empty;
        
        [Required]
        public double PlantedArea { get; set; } // en hectares
        
        [Required]
        public double ExpectedYield { get; set; } // en tonnes
        
        public double ActualYield { get; set; } = 0.0; // en tonnes
        
        [Required]
        public double TotalCost { get; set; } // en FCFA
        
        public double Revenue { get; set; } = 0.0; // en FCFA
        
        public double Profit { get; set; } = 0.0; // en FCFA
        
        [Required]
        public DateTime PlantingDate { get; set; }
        
        public DateTime? HarvestDate { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string Status { get; set; } = "planted"; // planted, growing, ready_to_harvest, harvested
        
        public string WeatherData { get; set; } = "{}"; // JSON string
        
        public string SoilData { get; set; } = "{}"; // JSON string
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
        
        // Propriétés calculées
        public double YieldPerHectare => PlantedArea > 0 ? ActualYield / PlantedArea : 0.0;
        
        public double ExpectedYieldPerHectare => PlantedArea > 0 ? ExpectedYield / PlantedArea : 0.0;
        
        public double ProfitPerHectare => PlantedArea > 0 ? Profit / PlantedArea : 0.0;
        
        public double CostPerHectare => PlantedArea > 0 ? TotalCost / PlantedArea : 0.0;
        
        public double RevenuePerHectare => PlantedArea > 0 ? Revenue / PlantedArea : 0.0;
        
        public double YieldEfficiency => ExpectedYield > 0 ? (ActualYield / ExpectedYield) * 100 : 0.0;
        
        public double ProfitMargin => Revenue > 0 ? (Profit / Revenue) * 100 : 0.0;
        
        public int GrowthDays => (DateTime.Now - PlantingDate).Days;
        
        public int DaysToHarvest
        {
            get
            {
                if (HarvestDate.HasValue)
                    return (HarvestDate.Value - DateTime.Now).Days;
                
                // Estimation basée sur le type de culture
                var cropDays = GetCropGrowthDays(CropType);
                return cropDays - GrowthDays;
            }
        }
        
        private int GetCropGrowthDays(string crop)
        {
            return crop.ToLower() switch
            {
                "maïs" or "mais" => 90,
                "riz" => 120,
                "arachide" => 100,
                "manioc" => 300,
                "igname" => 180,
                "tomate" => 75,
                "piment" => 80,
                "gombo" => 60,
                _ => 90
            };
        }
    }

    public class DashboardSummary
    {
        public int TotalCrops { get; set; }
        public double TotalArea { get; set; }
        public double TotalExpectedYield { get; set; }
        public double TotalActualYield { get; set; }
        public double TotalRevenue { get; set; }
        public double TotalProfit { get; set; }
        public double TotalCost { get; set; }
        public double AverageYieldEfficiency { get; set; }
        public double AverageProfitMargin { get; set; }
        public List<AgriculturalMetrics> RecentCrops { get; set; } = new();
        public Dictionary<string, double> CropsByType { get; set; } = new();
        public Dictionary<string, double> RevenueByRegion { get; set; } = new();
    }
}
