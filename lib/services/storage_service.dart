import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/models/trip_model.dart';
import '../shared/models/user_model.dart';
import '../features/history/widgets/history_filter.dart';

class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Box names
  static const String _tripsBoxName = 'trips';
  static const String _userBoxName = 'user';
  static const String _settingsBoxName = 'settings';

  // Boxes
  late Box<String> _tripsBox;
  late Box<String> _userBox;
  late Box<dynamic> _settingsBox;

  // Initialize storage
  Future<void> init() async {
    await Hive.initFlutter();

    _tripsBox = await Hive.openBox<String>(_tripsBoxName);
    _userBox = await Hive.openBox<String>(_userBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // ========== TRIP STORAGE ==========

  // Save a trip
  Future<void> saveTrip(Trip trip) async {
    final key = trip.id;
    final jsonString = jsonEncode(trip.toJson());
    await _tripsBox.put(key, jsonString);
  }

  // Get all trips
  Future<List<Trip>> getAllTrips() async {
    final List<Trip> trips = [];

    for (var key in _tripsBox.keys) {
      final jsonString = _tripsBox.get(key);
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        trips.add(Trip.fromJson(json));
      }
    }

    // Sort by timestamp (newest first)
    trips.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return trips;
  }

  // Get trips by filter
  Future<List<Trip>> getTrips(TimeFilter filter) async {
    final allTrips = await getAllTrips();
    final now = DateTime.now();

    return allTrips.where((trip) {
      switch (filter) {
        case TimeFilter.today:
          return trip.timestamp.year == now.year &&
              trip.timestamp.month == now.month &&
              trip.timestamp.day == now.day;

        case TimeFilter.thisWeek:
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          return trip.timestamp.isAfter(weekStart);

        case TimeFilter.thisMonth:
          return trip.timestamp.year == now.year &&
              trip.timestamp.month == now.month;
      }
    }).toList();
  }

  // Delete a trip
  Future<void> deleteTrip(String tripId) async {
    await _tripsBox.delete(tripId);
  }

  // Clear all trips
  Future<void> clearAllTrips() async {
    await _tripsBox.clear();
  }

  // Get trip count
  int getTripCount() {
    return _tripsBox.length;
  }

  // ========== USER STORAGE ==========

  // Save user
  Future<void> saveUser(UserModel user) async {
    final jsonString = jsonEncode(user.toJson());
    await _userBox.put('current_user', jsonString);
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final jsonString = _userBox.get('current_user');
    if (jsonString == null) return null;

    final json = jsonDecode(jsonString);
    return UserModel.fromJson(json);
  }

  // Clear user (logout)
  Future<void> clearUser() async {
    await _userBox.delete('current_user');
  }

  // ========== SETTINGS STORAGE ==========

  // Save setting
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  // Get setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  // Common settings helpers
  Future<void> saveLanguage(String language) async {
    await saveSetting('language', language);
  }

  String getLanguage() {
    return getSetting('language', defaultValue: 'fr') ?? 'fr';
  }

  Future<void> saveDefaultVehicle(String vehicle) async {
    await saveSetting('default_vehicle', vehicle);
  }

  String getDefaultVehicle() {
    return getSetting('default_vehicle', defaultValue: 'moto') ?? 'moto';
  }

  Future<void> saveHistoryEnabled(bool enabled) async {
    await saveSetting('history_enabled', enabled);
  }

  bool getHistoryEnabled() {
    return getSetting('history_enabled', defaultValue: false) ?? false;
  }

  // ========== FIRST LAUNCH ==========

  Future<void> setFirstLaunchDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
  }

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('first_launch') ?? true;
  }

  // ========== CACHE MANAGEMENT ==========

  // Calculate cache size (approximate)
  Future<int> getCacheSizeInBytes() async {
    int size = 0;

    // Trips box
    for (var key in _tripsBox.keys) {
      final value = _tripsBox.get(key);
      if (value != null) {
        size += value.length;
      }
    }

    // User box
    for (var key in _userBox.keys) {
      final value = _userBox.get(key);
      if (value != null) {
        size += value.length;
      }
    }

    return size;
  }

  // Clear all data (reset app)
  Future<void> clearAllData() async {
    await _tripsBox.clear();
    await _userBox.clear();
    await _settingsBox.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
