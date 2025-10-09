using AgricultureAPI.Models;

namespace AgricultureAPI.Services
{
    public interface IAgriculturalMetricsService
    {
        Task<IEnumerable<AgriculturalMetrics>> GetUserMetricsAsync(string userId);
        Task<AgriculturalMetrics?> GetMetricAsync(string id);
        Task<AgriculturalMetrics> CreateMetricAsync(AgriculturalMetrics metric);
        Task<AgriculturalMetrics> UpdateMetricAsync(AgriculturalMetrics metric);
        Task DeleteMetricAsync(string id);
        Task<DashboardSummary> GetDashboardSummaryAsync(string userId);
        Task<object> GetYieldPredictionsAsync(string cropType, string region);
        Task<IEnumerable<object>> GetAgriculturalAlertsAsync(string userId);
    }
}
