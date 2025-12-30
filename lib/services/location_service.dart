import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Nominatim API (Free, no API key needed)
  static const String _nominatimBase = 'https://nominatim.openstreetmap.org';

  // Lomé city bounds for better results
  static const double _lomeLat = 6.1319;
  static const double _lomeLng = 1.2227;
  static const double _searchRadius = 0.5; // ~50km radius

  // ========== CURRENT LOCATION ==========

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      // Check permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  // ========== GEOCODING ==========

  // Search places by query (autocomplete)
  Future<List<PlaceResult>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    try {
      // Build URL with Lomé bias
      final url = Uri.parse('$_nominatimBase/search').replace(
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': '10',
          'countrycodes': 'tg', // Togo only
          'viewbox':
              '${_lomeLng - _searchRadius},${_lomeLat - _searchRadius},'
              '${_lomeLng + _searchRadius},${_lomeLat + _searchRadius}',
          'bounded': '1',
          'addressdetails': '1',
        },
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'TaxiFare-Togo/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => PlaceResult.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  // Reverse geocode (coordinates to address)
  Future<String?> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    try {
      final url = Uri.parse('$_nominatimBase/reverse').replace(
        queryParameters: {
          'lat': lat.toString(),
          'lon': lng.toString(),
          'format': 'json',
          'addressdetails': '1',
        },
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'TaxiFare-Togo/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['display_name'] as String?;
      }

      return null;
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }

  // ========== POPULAR PLACES IN LOMÉ ==========

  // Get predefined popular places (for offline/quick access)
  List<PlaceResult> getPopularPlaces() {
    return [
      // Lieux emblématiques
      PlaceResult(
        displayName: 'Aéroport International Gnassingbé Eyadéma',
        lat: 6.1656,
        lng: 1.2545,
        type: 'airport',
      ),
      PlaceResult(
        displayName: 'Grand Marché de Lomé',
        lat: 6.1286,
        lng: 1.2126,
        type: 'market',
      ),
      PlaceResult(
        displayName: 'Port Autonome de Lomé',
        lat: 6.1165,
        lng: 1.2781,
        type: 'port',
      ),
      PlaceResult(
        displayName: 'Université de Lomé',
        lat: 6.1701,
        lng: 1.2065,
        type: 'university',
      ),
      PlaceResult(
        displayName: 'Stade de Kégué',
        lat: 6.1531,
        lng: 1.2314,
        type: 'stadium',
      ),
      PlaceResult(
        displayName: 'Hôpital CHU Sylvanus Olympio',
        lat: 6.1328,
        lng: 1.2089,
        type: 'hospital',
      ),
      PlaceResult(
        displayName: 'Marché d\'Assigamé',
        lat: 6.1923,
        lng: 1.1842,
        type: 'market',
      ),
      PlaceResult(
        displayName: 'Boulevard du 13 Janvier',
        lat: 6.1276,
        lng: 1.2318,
        type: 'road',
      ),
      PlaceResult(
        displayName: 'Carrefour Aéroport',
        lat: 6.1598,
        lng: 1.2387,
        type: 'junction',
      ),

      // Quartiers populaires
      PlaceResult(
        displayName: 'Tokoin',
        lat: 6.1453,
        lng: 1.2154,
        type: 'neighborhood',
      ),
      PlaceResult(
        displayName: 'Nyékonakpoè',
        lat: 6.1639,
        lng: 1.2445,
        type: 'neighborhood',
      ),
      PlaceResult(
        displayName: 'Agoè Nyivé',
        lat: 6.1953,
        lng: 1.1928,
        type: 'neighborhood',
      ),
      PlaceResult(
        displayName: 'Bè',
        lat: 6.1119,
        lng: 1.2436,
        type: 'neighborhood',
      ),
      PlaceResult(
        displayName: 'Adidogomé',
        lat: 6.1834,
        lng: 1.1756,
        type: 'neighborhood',
      ),
      PlaceResult(
        displayName: 'Cacaveli',
        lat: 6.1523,
        lng: 1.1987,
        type: 'neighborhood',
      ),
      PlaceResult(
        displayName: 'Hédzranawoé',
        lat: 6.1612,
        lng: 1.2198,
        type: 'neighborhood',
      ),
      PlaceResult(
        displayName: 'Amoutivé',
        lat: 6.1145,
        lng: 1.2287,
        type: 'neighborhood',
      ),
      PlaceResult(
        displayName: 'Kodjoviakopé',
        lat: 6.0987,
        lng: 1.2534,
        type: 'neighborhood',
      ),
      PlaceResult(
        displayName: 'Démakpoè',
        lat: 6.1389,
        lng: 1.1923,
        type: 'neighborhood',
      ),
      PlaceResult(
        displayName: 'Totsi',
        lat: 6.1256,
        lng: 1.1834,
        type: 'neighborhood',
      ),
      PlaceResult(
        displayName: 'Aflao Gakli',
        lat: 6.1734,
        lng: 1.2523,
        type: 'neighborhood',
      ),
      PlaceResult(
        displayName: 'Gbényédzi',
        lat: 6.1867,
        lng: 1.2134,
        type: 'neighborhood',
      ),
    ];
  }
}

// Place result model
class PlaceResult {
  final String displayName;
  final double lat;
  final double lng;
  final String type;
  final String? neighbourhood;
  final String? road;

  PlaceResult({
    required this.displayName,
    required this.lat,
    required this.lng,
    required this.type,
    this.neighbourhood,
    this.road,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;

    return PlaceResult(
      displayName: json['display_name'] as String,
      lat: double.parse(json['lat'] as String),
      lng: double.parse(json['lon'] as String),
      type: json['type'] as String? ?? 'unknown',
      neighbourhood: address?['neighbourhood'] as String?,
      road: address?['road'] as String?,
    );
  }

  // Short display name (for UI)
  String get shortName {
    final parts = displayName.split(',');
    return parts.length > 2 ? '${parts[0]}, ${parts[1]}' : displayName;
  }
}
