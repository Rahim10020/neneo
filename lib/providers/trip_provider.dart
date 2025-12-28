import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../shared/models/trip_model.dart';
import '../services/price_calculator_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';

class TripProvider with ChangeNotifier {
  final PriceCalculatorService _calculator = PriceCalculatorService();
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();

  Trip? _currentTrip;
  List<Trip> _history = [];
  bool _isCalculating = false;
  String? _error;

  Trip? get currentTrip => _currentTrip;
  List<Trip> get history => _history;
  bool get isCalculating => _isCalculating;
  String? get error => _error;

  // Calculate trip price
  Future<Trip?> calculateTrip({
    required String origin,
    required String destination,
    required String vehicleType,
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    _setCalculating(true);
    _error = null;

    try {
      // Calculate distance
      final distance = _calculator.calculateDistance(
        lat1: originLat,
        lon1: originLng,
        lat2: destLat,
        lon2: destLng,
      );

      // Calculate price
      final calculation = _calculator.calculatePrice(
        distanceKm: distance,
        vehicleType: vehicleType,
      );

      // Create trip
      final trip = Trip(
        id: const Uuid().v4(),
        origin: origin,
        destination: destination,
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
        distance: distance,
        vehicleType: vehicleType,
        price: calculation['prices']['ideal'],
        minPrice: calculation['prices']['min'],
        maxPrice: calculation['prices']['max'],
        isNightRate: calculation['isNightRate'],
        isWeekendRate: calculation['isWeekendRate'],
        timestamp: DateTime.now(),
      );

      _currentTrip = trip;

      _setCalculating(false);
      notifyListeners();
      return trip;
    } catch (e) {
      _error = 'Erreur de calcul: $e';
      _setCalculating(false);
      notifyListeners();
      return null;
    }
  }

  // Save trip to history
  Future<void> saveCurrentTrip() async {
    if (_currentTrip == null) return;

    try {
      await _storageService.saveTrip(_currentTrip!);
      await loadHistory();
    } catch (e) {
      print('Error saving trip: $e');
    }
  }

  // Load history from storage
  Future<void> loadHistory() async {
    try {
      _history = await _storageService.getAllTrips();
      notifyListeners();
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  // Delete trip from history
  Future<void> deleteTrip(String tripId) async {
    try {
      await _storageService.deleteTrip(tripId);
      _history.removeWhere((trip) => trip.id == tripId);
      notifyListeners();
    } catch (e) {
      print('Error deleting trip: $e');
    }
  }

  // Clear all history
  Future<void> clearHistory() async {
    try {
      await _storageService.clearAllTrips();
      _history.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  // Get price breakdown for current trip
  Map<String, dynamic>? getPriceBreakdown() {
    if (_currentTrip == null) return null;

    return _calculator.getPriceBreakdown(
      distanceKm: _currentTrip!.distance,
      vehicleType: _currentTrip!.vehicleType,
      tripTime: _currentTrip!.timestamp,
    );
  }

  // Search places
  Future<List<PlaceResult>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    try {
      return await _locationService.searchPlaces(query);
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  // Get popular places
  List<PlaceResult> getPopularPlaces() {
    return _locationService.getPopularPlaces();
  }

  // Get current location
  Future<PlaceResult?> getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) return null;

      final address = await _locationService.reverseGeocode(
        lat: position.latitude,
        lng: position.longitude,
      );

      return PlaceResult(
        displayName: address ?? 'Ma position actuelle',
        lat: position.latitude,
        lng: position.longitude,
        type: 'current',
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // Reset current trip
  void resetCurrentTrip() {
    _currentTrip = null;
    _error = null;
    notifyListeners();
  }

  void _setCalculating(bool value) {
    _isCalculating = value;
    notifyListeners();
  }
}
