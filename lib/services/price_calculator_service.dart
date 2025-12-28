import 'dart:math';
import '../shared/models/pricing_rule_model.dart';

class PriceCalculatorService {
  // Singleton pattern
  static final PriceCalculatorService _instance =
      PriceCalculatorService._internal();
  factory PriceCalculatorService() => _instance;
  PriceCalculatorService._internal();

  // Default pricing rules
  final Map<String, PricingRule> _rules = {
    'moto': PricingRule.defaultMotoRule(),
    'taxi': PricingRule.defaultTaxiRule(),
  };

  // Get pricing rule for vehicle type
  PricingRule getRule(String vehicleType) {
    return _rules[vehicleType] ?? _rules['moto']!;
  }

  // Update pricing rule (for admin features)
  void updateRule(String vehicleType, PricingRule rule) {
    _rules[vehicleType] = rule;
  }

  // Calculate price for a trip
  Map<String, dynamic> calculatePrice({
    required double distanceKm,
    required String vehicleType,
    DateTime? tripTime,
  }) {
    final time = tripTime ?? DateTime.now();
    final rule = getRule(vehicleType);

    // Get price calculation
    final prices = rule.calculatePrice(distanceKm, time);

    // Determine active multipliers
    final bool isNight = rule.isNightTime(time);
    final bool isWeekend = rule.isWeekend(time);

    return {
      'prices': prices,
      'distance': distanceKm,
      'vehicleType': vehicleType,
      'isNightRate': isNight,
      'isWeekendRate': isWeekend,
      'baseRatePerKm': rule.baseRatePerKm,
      'nightMultiplier': isNight ? rule.nightMultiplier : 1.0,
      'weekendMultiplier': isWeekend ? rule.weekendMultiplier : 1.0,
      'minimumPrice': rule.minimumPrice,
    };
  }

  // Calculate distance between two points (Haversine formula)
  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Get breakdown details for display
  Map<String, dynamic> getPriceBreakdown({
    required double distanceKm,
    required String vehicleType,
    DateTime? tripTime,
  }) {
    final time = tripTime ?? DateTime.now();
    final rule = getRule(vehicleType);
    final calculation = calculatePrice(
      distanceKm: distanceKm,
      vehicleType: vehicleType,
      tripTime: time,
    );

    final basePrice = calculation['prices']['base'] as int;
    final idealPrice = calculation['prices']['ideal'] as int;
    final isNight = calculation['isNightRate'] as bool;
    final isWeekend = calculation['isWeekendRate'] as bool;

    List<Map<String, dynamic>> breakdown = [
      {
        'label': 'Prix de base (${distanceKm.toStringAsFixed(1)} km)',
        'value': basePrice,
        'type': 'base',
      },
    ];

    if (isNight) {
      final nightSurcharge = (basePrice * (rule.nightMultiplier - 1)).round();
      breakdown.add({
        'label':
            'Supplément nuit (+${((rule.nightMultiplier - 1) * 100).round()}%)',
        'value': nightSurcharge,
        'type': 'surcharge',
      });
    }

    if (isWeekend) {
      final weekendSurcharge = (basePrice * (rule.weekendMultiplier - 1))
          .round();
      breakdown.add({
        'label':
            'Supplément weekend (+${((rule.weekendMultiplier - 1) * 100).round()}%)',
        'value': weekendSurcharge,
        'type': 'surcharge',
      });
    }

    breakdown.add({'label': 'Total', 'value': idealPrice, 'type': 'total'});

    return {'items': breakdown, 'total': idealPrice};
  }

  // Validate if a reported price is reasonable
  bool isPriceReasonable({
    required int reportedPrice,
    required int calculatedIdealPrice,
    double tolerancePercent = 30.0,
  }) {
    final minAcceptable = calculatedIdealPrice * (1 - tolerancePercent / 100);
    final maxAcceptable = calculatedIdealPrice * (1 + tolerancePercent / 100);

    return reportedPrice >= minAcceptable && reportedPrice <= maxAcceptable;
  }
}
