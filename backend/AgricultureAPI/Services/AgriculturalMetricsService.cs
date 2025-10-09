using AgricultureAPI.Models;
using AgricultureAPI.Repositories;

namespace AgricultureAPI.Services
{
    public class AgriculturalMetricsService : IAgriculturalMetricsService
    {
        private readonly IAgriculturalMetricsRepository _repository;

        public AgriculturalMetricsService(IAgriculturalMetricsRepository repository)
        {
            _repository = repository;
        }

        public async Task<IEnumerable<AgriculturalMetrics>> GetUserMetricsAsync(string userId)
        {
            if (string.IsNullOrEmpty(userId))
                throw new ArgumentException("User ID cannot be null or empty", nameof(userId));

            return await _repository.GetByUserIdAsync(userId);
        }

        public async Task<AgriculturalMetrics?> GetMetricAsync(string id)
        {
            if (string.IsNullOrEmpty(id))
                throw new ArgumentException("ID cannot be null or empty", nameof(id));

            return await _repository.GetByIdAsync(id);
        }

        public async Task<AgriculturalMetrics> CreateMetricAsync(AgriculturalMetrics metric)
        {
            if (metric == null)
                throw new ArgumentNullException(nameof(metric));

            if (string.IsNullOrEmpty(metric.UserId))
                throw new ArgumentException("User ID is required", nameof(metric));

            metric.Id = Guid.NewGuid().ToString();
            metric.CreatedAt = DateTime.UtcNow;
            metric.UpdatedAt = DateTime.UtcNow;

            return await _repository.CreateAsync(metric);
        }

        public async Task<AgriculturalMetrics> UpdateMetricAsync(AgriculturalMetrics metric)
        {
            if (metric == null)
                throw new ArgumentNullException(nameof(metric));

            if (string.IsNullOrEmpty(metric.Id))
                throw new ArgumentException("ID is required", nameof(metric));

            metric.UpdatedAt = DateTime.UtcNow;

            return await _repository.UpdateAsync(metric);
        }

        public async Task DeleteMetricAsync(string id)
        {
            if (string.IsNullOrEmpty(id))
                throw new ArgumentException("ID cannot be null or empty", nameof(id));

            await _repository.DeleteAsync(id);
        }

        public async Task<DashboardSummary> GetDashboardSummaryAsync(string userId)
        {
            if (string.IsNullOrEmpty(userId))
                throw new ArgumentException("User ID cannot be null or empty", nameof(userId));

            var metrics = await _repository.GetByUserIdAsync(userId);
            var metricsList = metrics.ToList();

            if (!metricsList.Any())
            {
                return new DashboardSummary();
            }

            var summary = new DashboardSummary
            {
                TotalFields = metricsList.Count,
                TotalArea = metricsList.Sum(m => m.FieldSize),
                TotalYield = metricsList.Sum(m => m.Yield),
                TotalRevenue = metricsList.Sum(m => m.Revenue),
                TotalCost = metricsList.Sum(m => m.Cost),
                TotalProfit = metricsList.Sum(m => m.Profit)
            };

            summary.AverageYieldPerHectare = summary.TotalArea > 0 ? summary.TotalYield / summary.TotalArea : 0;
            summary.AverageProfitPerHectare = summary.TotalArea > 0 ? summary.TotalProfit / summary.TotalArea : 0;

            // Group by crop type
            summary.CropSummaries = metricsList
                .GroupBy(m => m.CropType)
                .Select(g => new CropSummary
                {
                    CropType = g.Key,
                    FieldCount = g.Count(),
                    TotalArea = g.Sum(m => m.FieldSize),
                    TotalYield = g.Sum(m => m.Yield),
                    TotalRevenue = g.Sum(m => m.Revenue),
                    TotalProfit = g.Sum(m => m.Profit),
                    AverageYieldPerHectare = g.Sum(m => m.FieldSize) > 0 ? g.Sum(m => m.Yield) / g.Sum(m => m.FieldSize) : 0
                })
                .ToList();

            // Group by month
            summary.MonthlyTrends = metricsList
                .GroupBy(m => new { m.HarvestDate.Year, m.HarvestDate.Month })
                .Select(g => new MonthlyMetrics
                {
                    Year = g.Key.Year,
                    Month = g.Key.Month,
                    TotalYield = g.Sum(m => m.Yield),
                    TotalRevenue = g.Sum(m => m.Revenue),
                    TotalCost = g.Sum(m => m.Cost),
                    TotalProfit = g.Sum(m => m.Profit)
                })
                .OrderBy(m => m.Year)
                .ThenBy(m => m.Month)
                .ToList();

            return summary;
        }

        public async Task<object> GetYieldPredictionsAsync(string cropType, string region)
        {
            if (string.IsNullOrEmpty(cropType))
                throw new ArgumentException("Crop type cannot be null or empty", nameof(cropType));

            if (string.IsNullOrEmpty(region))
                throw new ArgumentException("Region cannot be null or empty", nameof(region));

            // Simple prediction based on historical data
            var historicalData = await _repository.GetByCropTypeAndRegionAsync(cropType, region);
            var dataList = historicalData.ToList();

            if (!dataList.Any())
            {
                return new { prediction = 0, confidence = 0, message = "No historical data available" };
            }

            var averageYield = dataList.Average(m => m.YieldPerHectare);
            var trend = CalculateTrend(dataList);
            var prediction = averageYield * (1 + trend);

            return new
            {
                prediction = Math.Round(prediction, 2),
                confidence = Math.Min(95, Math.Max(50, 100 - (dataList.Count * 5))),
                trend = trend > 0 ? "increasing" : trend < 0 ? "decreasing" : "stable",
                historicalAverage = Math.Round(averageYield, 2),
                dataPoints = dataList.Count
            };
        }

        public async Task<IEnumerable<object>> GetAgriculturalAlertsAsync(string userId)
        {
            if (string.IsNullOrEmpty(userId))
                throw new ArgumentException("User ID cannot be null or empty", nameof(userId));

            var metrics = await _repository.GetByUserIdAsync(userId);
            var alerts = new List<object>();

            foreach (var metric in metrics)
            {
                // Low yield alert
                if (metric.YieldPerHectare < 2.0)
                {
                    alerts.Add(new
                    {
                        type = "low_yield",
                        severity = "warning",
                        message = $"Low yield detected for {metric.CropType}: {metric.YieldPerHectare:F2} tonnes/hectare",
                        fieldLocation = metric.FieldLocation,
                        date = metric.HarvestDate
                    });
                }

                // High cost alert
                if (metric.CostPerHectare > 500000)
                {
                    alerts.Add(new
                    {
                        type = "high_cost",
                        severity = "info",
                        message = $"High production cost for {metric.CropType}: {metric.CostPerHectare:F0} FCFA/hectare",
                        fieldLocation = metric.FieldLocation,
                        date = metric.HarvestDate
                    });
                }

                // Negative profit alert
                if (metric.Profit < 0)
                {
                    alerts.Add(new
                    {
                        type = "loss",
                        severity = "critical",
                        message = $"Loss detected for {metric.CropType}: {metric.Profit:F0} FCFA",
                        fieldLocation = metric.FieldLocation,
                        date = metric.HarvestDate
                    });
                }
            }

            return alerts;
        }

        private double CalculateTrend(IEnumerable<AgriculturalMetrics> data)
        {
            var orderedData = data.OrderBy(m => m.HarvestDate).ToList();
            if (orderedData.Count < 2) return 0;

            var firstHalf = orderedData.Take(orderedData.Count / 2).Average(m => m.YieldPerHectare);
            var secondHalf = orderedData.Skip(orderedData.Count / 2).Average(m => m.YieldPerHectare);

            return firstHalf > 0 ? (secondHalf - firstHalf) / firstHalf : 0;
        }
    }
}
