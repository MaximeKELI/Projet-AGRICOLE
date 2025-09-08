class Region {
  final String id;
  final String name;
  final List<Prefecture> prefectures;

  Region({
    required this.id,
    required this.name,
    required this.prefectures,
  });
}

class Prefecture {
  final String id;
  final String name;
  final String regionId;
  final List<Commune> communes;

  Prefecture({
    required this.id,
    required this.name,
    required this.regionId,
    required this.communes,
  });
}

class Commune {
  final String id;
  final String name;
  final String prefectureId;
  final SoilType soilType;
  final double latitude;
  final double longitude;

  Commune({
    required this.id,
    required this.name,
    required this.prefectureId,
    required this.soilType,
    required this.latitude,
    required this.longitude,
  });
}

class SoilType {
  final String id;
  final String name;
  final String description;
  final String characteristics;
  final double ph;
  final String texture;
  final String drainage;
  final List<String> suitableCrops;

  SoilType({
    required this.id,
    required this.name,
    required this.description,
    required this.characteristics,
    required this.ph,
    required this.texture,
    required this.drainage,
    required this.suitableCrops,
  });
}

class Crop {
  final String id;
  final String name;
  final String description;
  final List<String> suitableSoilTypes;
  final int growthDurationDays;
  final String plantingSeason;
  final TechnicalItinerary technicalItinerary;

  Crop({
    required this.id,
    required this.name,
    required this.description,
    required this.suitableSoilTypes,
    required this.growthDurationDays,
    required this.plantingSeason,
    required this.technicalItinerary,
  });
}

class TechnicalItinerary {
  final String cropId;
  final List<CropActivity> activities;
  final PlantingSchedule plantingSchedule;

  TechnicalItinerary({
    required this.cropId,
    required this.activities,
    required this.plantingSchedule,
  });
}

class CropActivity {
  final String id;
  final String name;
  final String description;
  final int dayFromPlanting;
  final String category; // preparation, planting, maintenance, harvest
  final bool isReminder;

  CropActivity({
    required this.id,
    required this.name,
    required this.description,
    required this.dayFromPlanting,
    required this.category,
    this.isReminder = false,
  });
}

class PlantingSchedule {
  final String cropId;
  final DateTime optimalStartDate;
  final DateTime optimalEndDate;
  final String climateConsiderations;

  PlantingSchedule({
    required this.cropId,
    required this.optimalStartDate,
    required this.optimalEndDate,
    required this.climateConsiderations,
  });
}

class WeatherAlert {
  final String id;
  final String type; // rain, drought, temperature, wind
  final String severity; // low, medium, high
  final String message;
  final DateTime startDate;
  final DateTime? endDate;
  final String recommendations;

  WeatherAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.startDate,
    this.endDate,
    required this.recommendations,
  });
}
