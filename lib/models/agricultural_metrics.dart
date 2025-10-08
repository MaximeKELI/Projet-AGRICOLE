class AgriculturalMetrics {
  final String id;
  final String userId;
  final String cropType;
  final String region;
  final double plantedArea; // en hectares
  final double expectedYield; // en tonnes
  final double actualYield; // en tonnes
  final double totalCost; // en FCFA
  final double revenue; // en FCFA
  final double profit; // en FCFA
  final DateTime plantingDate;
  final DateTime? harvestDate;
  final String status; // planted, growing, ready_to_harvest, harvested
  final Map<String, dynamic> weatherData;
  final Map<String, dynamic> soilData;
  final DateTime createdAt;
  final DateTime updatedAt;

  AgriculturalMetrics({
    required this.id,
    required this.userId,
    required this.cropType,
    required this.region,
    required this.plantedArea,
    required this.expectedYield,
    this.actualYield = 0.0,
    required this.totalCost,
    this.revenue = 0.0,
    this.profit = 0.0,
    required this.plantingDate,
    this.harvestDate,
    this.status = 'planted',
    this.weatherData = const {},
    this.soilData = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory AgriculturalMetrics.fromJson(Map<String, dynamic> json) {
    return AgriculturalMetrics(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      cropType: json['cropType'] ?? '',
      region: json['region'] ?? '',
      plantedArea: (json['plantedArea'] ?? 0.0).toDouble(),
      expectedYield: (json['expectedYield'] ?? 0.0).toDouble(),
      actualYield: (json['actualYield'] ?? 0.0).toDouble(),
      totalCost: (json['totalCost'] ?? 0.0).toDouble(),
      revenue: (json['revenue'] ?? 0.0).toDouble(),
      profit: (json['profit'] ?? 0.0).toDouble(),
      plantingDate: DateTime.parse(json['plantingDate'] ?? DateTime.now().toIso8601String()),
      harvestDate: json['harvestDate'] != null ? DateTime.parse(json['harvestDate']) : null,
      status: json['status'] ?? 'planted',
      weatherData: Map<String, dynamic>.from(json['weatherData'] ?? {}),
      soilData: Map<String, dynamic>.from(json['soilData'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'cropType': cropType,
      'region': region,
      'plantedArea': plantedArea,
      'expectedYield': expectedYield,
      'actualYield': actualYield,
      'totalCost': totalCost,
      'revenue': revenue,
      'profit': profit,
      'plantingDate': plantingDate.toIso8601String(),
      'harvestDate': harvestDate?.toIso8601String(),
      'status': status,
      'weatherData': weatherData,
      'soilData': soilData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Calculs automatiques
  double get yieldPerHectare => plantedArea > 0 ? actualYield / plantedArea : 0.0;
  double get expectedYieldPerHectare => plantedArea > 0 ? expectedYield / plantedArea : 0.0;
  double get profitPerHectare => plantedArea > 0 ? profit / plantedArea : 0.0;
  double get costPerHectare => plantedArea > 0 ? totalCost / plantedArea : 0.0;
  double get revenuePerHectare => plantedArea > 0 ? revenue / plantedArea : 0.0;
  double get yieldEfficiency => expectedYield > 0 ? (actualYield / expectedYield) * 100 : 0.0;
  double get profitMargin => revenue > 0 ? (profit / revenue) * 100 : 0.0;

  // Durée de croissance
  int get growthDays => DateTime.now().difference(plantingDate).inDays;
  int get daysToHarvest {
    if (harvestDate != null) return harvestDate!.difference(DateTime.now()).inDays;
    // Estimation basée sur le type de culture
    final cropDays = _getCropGrowthDays(cropType);
    return cropDays - growthDays;
  }

  int _getCropGrowthDays(String crop) {
    switch (crop.toLowerCase()) {
      case 'maïs':
      case 'mais':
        return 90;
      case 'riz':
        return 120;
      case 'arachide':
        return 100;
      case 'manioc':
        return 300;
      case 'igname':
        return 180;
      case 'tomate':
        return 75;
      case 'piment':
        return 80;
      case 'gombo':
        return 60;
      default:
        return 90;
    }
  }

  // Mise à jour des métriques
  AgriculturalMetrics copyWith({
    String? id,
    String? userId,
    String? cropType,
    String? region,
    double? plantedArea,
    double? expectedYield,
    double? actualYield,
    double? totalCost,
    double? revenue,
    double? profit,
    DateTime? plantingDate,
    DateTime? harvestDate,
    String? status,
    Map<String, dynamic>? weatherData,
    Map<String, dynamic>? soilData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgriculturalMetrics(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cropType: cropType ?? this.cropType,
      region: region ?? this.region,
      plantedArea: plantedArea ?? this.plantedArea,
      expectedYield: expectedYield ?? this.expectedYield,
      actualYield: actualYield ?? this.actualYield,
      totalCost: totalCost ?? this.totalCost,
      revenue: revenue ?? this.revenue,
      profit: profit ?? this.profit,
      plantingDate: plantingDate ?? this.plantingDate,
      harvestDate: harvestDate ?? this.harvestDate,
      status: status ?? this.status,
      weatherData: weatherData ?? this.weatherData,
      soilData: soilData ?? this.soilData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DashboardSummary {
  final int totalCrops;
  final double totalArea;
  final double totalExpectedYield;
  final double totalActualYield;
  final double totalRevenue;
  final double totalProfit;
  final double totalCost;
  final double averageYieldEfficiency;
  final double averageProfitMargin;
  final List<AgriculturalMetrics> recentCrops;
  final Map<String, double> cropsByType;
  final Map<String, double> revenueByRegion;

  DashboardSummary({
    required this.totalCrops,
    required this.totalArea,
    required this.totalExpectedYield,
    required this.totalActualYield,
    required this.totalRevenue,
    required this.totalProfit,
    required this.totalCost,
    required this.averageYieldEfficiency,
    required this.averageProfitMargin,
    required this.recentCrops,
    required this.cropsByType,
    required this.revenueByRegion,
  });

  factory DashboardSummary.fromMetrics(List<AgriculturalMetrics> metrics) {
    if (metrics.isEmpty) {
      return DashboardSummary(
        totalCrops: 0,
        totalArea: 0.0,
        totalExpectedYield: 0.0,
        totalActualYield: 0.0,
        totalRevenue: 0.0,
        totalProfit: 0.0,
        totalCost: 0.0,
        averageYieldEfficiency: 0.0,
        averageProfitMargin: 0.0,
        recentCrops: [],
        cropsByType: {},
        revenueByRegion: {},
      );
    }

    final totalArea = metrics.fold(0.0, (sum, metric) => sum + metric.plantedArea);
    final totalExpectedYield = metrics.fold(0.0, (sum, metric) => sum + metric.expectedYield);
    final totalActualYield = metrics.fold(0.0, (sum, metric) => sum + metric.actualYield);
    final totalRevenue = metrics.fold(0.0, (sum, metric) => sum + metric.revenue);
    final totalProfit = metrics.fold(0.0, (sum, metric) => sum + metric.profit);
    final totalCost = metrics.fold(0.0, (sum, metric) => sum + metric.totalCost);

    final averageYieldEfficiency = metrics.isNotEmpty
        ? metrics.fold(0.0, (sum, metric) => sum + metric.yieldEfficiency) / metrics.length
        : 0.0;

    final averageProfitMargin = totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0.0;

    // Grouper par type de culture
    final cropsByType = <String, double>{};
    for (final metric in metrics) {
      cropsByType[metric.cropType] = (cropsByType[metric.cropType] ?? 0.0) + metric.plantedArea;
    }

    // Grouper par région
    final revenueByRegion = <String, double>{};
    for (final metric in metrics) {
      revenueByRegion[metric.region] = (revenueByRegion[metric.region] ?? 0.0) + metric.revenue;
    }

    // Trier par date de création (plus récent en premier)
    final recentCrops = List<AgriculturalMetrics>.from(metrics)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return DashboardSummary(
      totalCrops: metrics.length,
      totalArea: totalArea,
      totalExpectedYield: totalExpectedYield,
      totalActualYield: totalActualYield,
      totalRevenue: totalRevenue,
      totalProfit: totalProfit,
      totalCost: totalCost,
      averageYieldEfficiency: averageYieldEfficiency,
      averageProfitMargin: averageProfitMargin,
      recentCrops: recentCrops.take(5).toList(),
      cropsByType: cropsByType,
      revenueByRegion: revenueByRegion,
    );
  }
}
