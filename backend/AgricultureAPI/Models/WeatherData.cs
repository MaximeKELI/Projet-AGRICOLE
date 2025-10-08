using System.ComponentModel.DataAnnotations;

namespace AgricultureAPI.Models
{
    public class WeatherData
    {
        [Key]
        public string Id { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(200)]
        public string Location { get; set; } = string.Empty;
        
        [Required]
        public double Latitude { get; set; }
        
        [Required]
        public double Longitude { get; set; }
        
        [Required]
        public double Temperature { get; set; } // en Celsius
        
        [Required]
        public double Humidity { get; set; } // en pourcentage
        
        [Required]
        public double Pressure { get; set; } // en hPa
        
        [Required]
        public double WindSpeed { get; set; } // en km/h
        
        [Required]
        public double WindDirection { get; set; } // en degrés
        
        [Required]
        public double Rainfall { get; set; } // en mm
        
        [Required]
        public double UvIndex { get; set; }
        
        [Required]
        [MaxLength(100)]
        public string Condition { get; set; } = string.Empty;
        
        [MaxLength(500)]
        public string Description { get; set; } = string.Empty;
        
        [Required]
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
        
        public string Forecast { get; set; } = "{}"; // JSON string
        
        // Propriétés calculées pour l'agriculture
        public double HeatIndex => Temperature + (0.5 * Humidity) - 32;
        
        public double DewPoint => Temperature - ((100 - Humidity) / 5);
        
        public bool IsFavorableForPlanting => Temperature >= 20 && Temperature <= 35 && 
                                              Humidity >= 40 && Humidity <= 80 && 
                                              Rainfall <= 5;
        
        public bool IsFavorableForHarvest => Rainfall <= 2 && WindSpeed <= 20;
        
        public string AgriculturalAdvice
        {
            get
            {
                if (Rainfall > 10) return "Éviter les travaux agricoles - pluie intense";
                if (Temperature > 35) return "Protéger les cultures de la chaleur excessive";
                if (Humidity > 85) return "Risque élevé de maladies fongiques";
                if (WindSpeed > 25) return "Éviter l'application de pesticides";
                if (UvIndex > 8) return "Protéger les cultures sensibles aux UV";
                return "Conditions favorables pour les travaux agricoles";
            }
        }
        
        public string IrrigationAdvice
        {
            get
            {
                if (Rainfall > 5) return "Irrigation non nécessaire - pluie suffisante";
                if (Humidity < 40) return "Irrigation recommandée - humidité faible";
                if (Temperature > 30 && Humidity < 60) return "Irrigation nécessaire - chaleur et sécheresse";
                return "Irrigation modérée recommandée";
            }
        }
        
        public List<string> DiseaseRisk
        {
            get
            {
                var risks = new List<string>();
                
                if (Humidity > 80)
                    risks.Add("Risque élevé de maladies fongiques");
                if (DewPoint > 20)
                    risks.Add("Risque de mildiou");
                if (Temperature > 25 && Humidity > 70)
                    risks.Add("Risque de rouille");
                if (Temperature < 15 && Humidity > 60)
                    risks.Add("Risque de pourriture");
                
                return risks;
            }
        }
    }

    public class WeatherForecast
    {
        [Key]
        public string Id { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(200)]
        public string Location { get; set; } = string.Empty;
        
        [Required]
        public double Latitude { get; set; }
        
        [Required]
        public double Longitude { get; set; }
        
        public string DailyForecast { get; set; } = "[]"; // JSON string
        
        public string HourlyForecast { get; set; } = "[]"; // JSON string
        
        public string AgriculturalRecommendations { get; set; } = "{}"; // JSON string
        
        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        [Required]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }

    public class WeatherAlert
    {
        [Key]
        public string Id { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(50)]
        public string Type { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(20)]
        public string Severity { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(1000)]
        public string Message { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(200)]
        public string Location { get; set; } = string.Empty;
        
        [Required]
        public DateTime StartTime { get; set; }
        
        [Required]
        public DateTime EndTime { get; set; }
        
        public string Recommendations { get; set; } = "[]"; // JSON string
        
        [Required]
        public bool IsActive { get; set; } = true;
        
        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        [Required]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
        
        // Propriétés calculées
        public string SeverityColor
        {
            get
            {
                return Severity.ToLower() switch
                {
                    "critical" => "#FF0000",
                    "warning" => "#FFA500",
                    "info" => "#0000FF",
                    _ => "#808080"
                };
            }
        }
        
        public string SeverityIcon
        {
            get
            {
                return Severity.ToLower() switch
                {
                    "critical" => "dangerous",
                    "warning" => "warning",
                    "info" => "info",
                    _ => "notifications"
                };
            }
        }
    }
}
