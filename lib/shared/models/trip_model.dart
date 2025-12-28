import 'package:intl/intl.dart';

class Trip {
  final String id;
  final String origin;
  final String destination;
  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;
  final double distance;
  final String vehicleType; // 'moto' or 'taxi'
  final int price;
  final int minPrice;
  final int maxPrice;
  final bool isNightRate;
  final bool isWeekendRate;
  final DateTime timestamp;
  final String userId;

  Trip({
    required this.id,
    required this.origin,
    required this.destination,
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    required this.distance,
    required this.vehicleType,
    required this.price,
    required this.minPrice,
    required this.maxPrice,
    required this.isNightRate,
    required this.isWeekendRate,
    required this.timestamp,
    this.userId = '',
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'origin': origin,
      'destination': destination,
      'originLat': originLat,
      'originLng': originLng,
      'destLat': destLat,
      'destLng': destLng,
      'distance': distance,
      'vehicleType': vehicleType,
      'price': price,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'isNightRate': isNightRate,
      'isWeekendRate': isWeekendRate,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }

  // Create from JSON
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      originLat: (json['originLat'] as num).toDouble(),
      originLng: (json['originLng'] as num).toDouble(),
      destLat: (json['destLat'] as num).toDouble(),
      destLng: (json['destLng'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      vehicleType: json['vehicleType'] as String,
      price: json['price'] as int,
      minPrice: json['minPrice'] as int,
      maxPrice: json['maxPrice'] as int,
      isNightRate: json['isNightRate'] as bool,
      isWeekendRate: json['isWeekendRate'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String? ?? '',
    );
  }

  // Helper methods
  String get formattedDate => DateFormat('dd/MM/yyyy').format(timestamp);
  String get formattedTime => DateFormat('HH:mm').format(timestamp);
  String get formattedDateTime =>
      DateFormat('dd/MM/yyyy HH:mm').format(timestamp);

  String get vehicleDisplayName => vehicleType == 'moto' ? 'Zémidjan' : 'Taxi';

  String get route => '$origin → $destination';

  // Calculate price range percentage
  double get priceVariance => ((maxPrice - minPrice) / price * 100);
}
