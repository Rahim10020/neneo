class PricingRule {
  final String id;
  final String vehicleType; // 'moto' or 'taxi'
  final int baseRatePerKm; // in CFA
  final int minimumPrice; // in CFA
  final double nightMultiplier; // e.g., 1.30 for +30%
  final double weekendMultiplier; // e.g., 1.20 for +20%
  final int startHourNight; // 20 for 8PM
  final int endHourNight; // 6 for 6AM
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PricingRule({
    required this.id,
    required this.vehicleType,
    required this.baseRatePerKm,
    required this.minimumPrice,
    this.nightMultiplier = 1.30,
    this.weekendMultiplier = 1.20,
    this.startHourNight = 20,
    this.endHourNight = 6,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  // Default rules
  static PricingRule defaultMotoRule() {
    return PricingRule(
      id: 'moto_default',
      vehicleType: 'moto',
      baseRatePerKm: 100,
      minimumPrice: 300, // Tarif minimum réaliste pour Lomé
      nightMultiplier: 1.30,
      weekendMultiplier: 1.20,
      startHourNight: 20,
      endHourNight: 6,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  static PricingRule defaultTaxiRule() {
    return PricingRule(
      id: 'taxi_default',
      vehicleType: 'taxi',
      baseRatePerKm: 150,
      minimumPrice: 500,
      nightMultiplier: 1.30,
      weekendMultiplier: 1.20,
      startHourNight: 20,
      endHourNight: 6,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  // Check if current time is night
  bool isNightTime(DateTime time) {
    final hour = time.hour;
    return hour >= startHourNight || hour < endHourNight;
  }

  // Check if current date is weekend
  bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  // Calculate price based on distance
  Map<String, int> calculatePrice(double distanceKm, DateTime tripTime) {
    // Base price
    int basePrice = (distanceKm * baseRatePerKm).round();

    // Apply minimum
    if (basePrice < minimumPrice) {
      basePrice = minimumPrice;
    }

    // Apply multipliers
    double multiplier = 1.0;
    if (isNightTime(tripTime)) {
      multiplier *= nightMultiplier;
    }
    if (isWeekend(tripTime)) {
      multiplier *= weekendMultiplier;
    }

    int finalPrice = (basePrice * multiplier).round();

    // Calculate range (±15%)
    int minPrice = (finalPrice * 0.85).round();
    int maxPrice = (finalPrice * 1.15).round();

    return {
      'ideal': finalPrice,
      'min': minPrice,
      'max': maxPrice,
      'base': basePrice,
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleType': vehicleType,
      'baseRatePerKm': baseRatePerKm,
      'minimumPrice': minimumPrice,
      'nightMultiplier': nightMultiplier,
      'weekendMultiplier': weekendMultiplier,
      'startHourNight': startHourNight,
      'endHourNight': endHourNight,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory PricingRule.fromJson(Map<String, dynamic> json) {
    return PricingRule(
      id: json['id'] as String,
      vehicleType: json['vehicleType'] as String,
      baseRatePerKm: json['baseRatePerKm'] as int,
      minimumPrice: json['minimumPrice'] as int,
      nightMultiplier: (json['nightMultiplier'] as num?)?.toDouble() ?? 1.30,
      weekendMultiplier:
          (json['weekendMultiplier'] as num?)?.toDouble() ?? 1.20,
      startHourNight: json['startHourNight'] as int? ?? 20,
      endHourNight: json['endHourNight'] as int? ?? 6,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
