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
        [MaxLength(200)]
        public string FieldLocation { get; set; } = string.Empty;
        
        [Required]
        public double FieldSize { get; set; } // en hectares
        
        [Required]
        public double Yield { get; set; } // en tonnes
        
        [Required]
        public double YieldPerHectare => FieldSize > 0 ? Yield / FieldSize : 0;
        
        [Required]
        public DateTime PlantingDate { get; set; }
        
        [Required]
        public DateTime HarvestDate { get; set; }
        
        [Required]
        public double WaterUsage { get; set; } // en litres
        
        [Required]
        public double FertilizerUsage { get; set; } // en kg
        
        [Required]
        public double PesticideUsage { get; set; } // en litres
        
        [Required]
        public double LaborHours { get; set; }
        
        [Required]
        public double Cost { get; set; } // en francs CFA
        
        [Required]
        public double Revenue { get; set; } // en francs CFA
        
        public double Profit => Revenue - Cost;
        
        public double ProfitPerHectare => FieldSize > 0 ? Profit / FieldSize : 0;
        
        public double CostPerHectare => FieldSize > 0 ? Cost / FieldSize : 0;
        
        [MaxLength(1000)]
        public string Notes { get; set; } = string.Empty;
        
        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        [Required]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }

    public class DashboardSummary
    {
        public int TotalFields { get; set; }
        public double TotalArea { get; set; }
        public double TotalYield { get; set; }
        public double AverageYieldPerHectare { get; set; }
        public double TotalRevenue { get; set; }
        public double TotalCost { get; set; }
        public double TotalProfit { get; set; }
        public double AverageProfitPerHectare { get; set; }
        public List<CropSummary> CropSummaries { get; set; } = new();
        public List<MonthlyMetrics> MonthlyTrends { get; set; } = new();
    }

    public class CropSummary
    {
        public string CropType { get; set; } = string.Empty;
        public int FieldCount { get; set; }
        public double TotalArea { get; set; }
        public double TotalYield { get; set; }
        public double AverageYieldPerHectare { get; set; }
        public double TotalRevenue { get; set; }
        public double TotalProfit { get; set; }
    }

    public class MonthlyMetrics
    {
        public int Year { get; set; }
        public int Month { get; set; }
        public double TotalYield { get; set; }
        public double TotalRevenue { get; set; }
        public double TotalCost { get; set; }
        public double TotalProfit { get; set; }
    }
}