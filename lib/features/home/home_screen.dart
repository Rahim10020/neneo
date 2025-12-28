import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/trip_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/location_service.dart';
import 'widgets/location_input.dart';
import 'widgets/vehicle_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Location data
  PlaceResult? _originPlace;
  PlaceResult? _destinationPlace;

  // Selected vehicle
  VehicleType _selectedVehicle = VehicleType.zemidjan;

  // Controllers
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  // Search results
  List<PlaceResult> _originSuggestions = [];
  List<PlaceResult> _destinationSuggestions = [];

  // Loading states
  bool _isSearchingOrigin = false;
  bool _isSearchingDestination = false;
  bool _isGettingLocation = false;

  // Night rate detection
  bool _isNightRate = false;

  @override
  void initState() {
    super.initState();
    _checkNightRate();
    _loadUserPreferences();

    // Debounced search
    _originController.addListener(_onOriginChanged);
    _destinationController.addListener(_onDestinationChanged);
  }

  void _checkNightRate() {
    final hour = DateTime.now().hour;
    setState(() {
      _isNightRate = hour >= 20 || hour < 6;
    });
  }

  void _loadUserPreferences() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _selectedVehicle = userProvider.user.defaultVehicle == 'moto'
          ? VehicleType.zemidjan
          : VehicleType.taxi;
    });
  }

  void _onOriginChanged() {
    if (_originController.text.isEmpty) {
      setState(() => _originSuggestions = []);
      return;
    }

    _searchOrigin(_originController.text);
  }

  void _onDestinationChanged() {
    if (_destinationController.text.isEmpty) {
      setState(() => _destinationSuggestions = []);
      return;
    }

    _searchDestination(_destinationController.text);
  }

  Future<void> _searchOrigin(String query) async {
    if (query.length < 2) return;

    setState(() => _isSearchingOrigin = true);

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final results = await tripProvider.searchPlaces(query);

    setState(() {
      _originSuggestions = results;
      _isSearchingOrigin = false;
    });
  }

  Future<void> _searchDestination(String query) async {
    if (query.length < 2) return;

    setState(() => _isSearchingDestination = true);

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final results = await tripProvider.searchPlaces(query);

    setState(() {
      _destinationSuggestions = results;
      _isSearchingDestination = false;
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final location = await tripProvider.getCurrentLocation();

    if (location != null) {
      setState(() {
        _originPlace = location;
        _originController.text = location.shortName;
        _originSuggestions = [];
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'obtenir votre position'),
          backgroundColor: AppColors.error,
        ),
      );
    }

    setState(() => _isGettingLocation = false);
  }

  Future<void> _onCalculatePrice() async {
    // Validation
    if (_originPlace == null || _destinationPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un départ et une destination'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    // Calculate trip
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final trip = await tripProvider.calculateTrip(
      origin: _originPlace!.shortName,
      destination: _destinationPlace!.shortName,
      vehicleType: _selectedVehicle == VehicleType.zemidjan ? 'moto' : 'taxi',
      originLat: _originPlace!.lat,
      originLng: _originPlace!.lng,
      destLat: _destinationPlace!.lat,
      destLng: _destinationPlace!.lng,
    );

    // Close loading
    if (!mounted) return;
    Navigator.pop(context);

    if (trip != null) {
      // Save trip if Pro user
      if (userProvider.isPro) {
        await tripProvider.saveCurrentTrip();
      }

      // Navigate to result
      if (!mounted) return;
      Navigator.pushNamed(context, AppConstants.routeResult, arguments: trip);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tripProvider.error ?? 'Erreur de calcul'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _swapLocations() {
    final tempPlace = _originPlace;
    final tempText = _originController.text;

    setState(() {
      _originPlace = _destinationPlace;
      _originController.text = _destinationController.text;

      _destinationPlace = tempPlace;
      _destinationController.text = tempText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppConstants.appName, style: AppTextStyles.h2),
                    Row(
                      children: [
                        Icon(
                          Icons.motorcycle,
                          color: AppColors.textPrimary,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppConstants.routeSettings,
                          ),
                          child: Icon(
                            Icons.settings_outlined,
                            color: AppColors.textPrimary,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Origin Input
                LocationInput(
                  label: 'POINT DE DEPART',
                  controller: _originController,
                  icon: Icons.radio_button_checked,
                  iconColor: AppColors.error,
                  suggestions: _originSuggestions,
                  isLoading: _isSearchingOrigin,
                  onSuggestionSelected: (place) {
                    setState(() {
                      _originPlace = place;
                      _originController.text = place.shortName;
                      _originSuggestions = [];
                    });
                  },
                ),

                const SizedBox(height: 8),

                // Use current location & swap button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _isGettingLocation
                              ? null
                              : _useCurrentLocation,
                          child: Row(
                            children: [
                              if (_isGettingLocation)
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.success,
                                  ),
                                )
                              else
                                Icon(
                                  Icons.my_location,
                                  color: AppColors.success,
                                  size: 18,
                                ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Utiliser ma position actuelle',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _swapLocations,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.gray100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.swap_vert,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Destination Input
                LocationInput(
                  label: 'DESTINATION',
                  controller: _destinationController,
                  icon: Icons.location_on,
                  iconColor: AppColors.success,
                  suggestions: _destinationSuggestions,
                  isLoading: _isSearchingDestination,
                  onSuggestionSelected: (place) {
                    setState(() {
                      _destinationPlace = place;
                      _destinationController.text = place.shortName;
                      _destinationSuggestions = [];
                    });
                  },
                ),

                const SizedBox(height: 32),

                // Vehicle Selector Section
                Text(
                  'CHOISIR UN VEHICULE',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray500,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 16),

                VehicleSelector(
                  selectedVehicle: _selectedVehicle,
                  onVehicleSelected: (vehicle) {
                    setState(() => _selectedVehicle = vehicle);
                  },
                ),

                const SizedBox(height: 24),

                // Night rate indicator
                if (_isNightRate)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.nightlight_round,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Tarif de nuit: +30%',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // Calculate Button
                Consumer<TripProvider>(
                  builder: (context, tripProvider, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: tripProvider.isCalculating
                            ? null
                            : _onCalculatePrice,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: tripProvider.isCalculating
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textPrimary,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Calculer le prix',
                                    style: AppTextStyles.button,
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.directions_walk,
                                    size: 20,
                                    color: AppColors.textPrimary,
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),

                // Pro badge (if user is Pro)
                if (userProvider.isPro) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFEB3B), Color(0xFFFDD835)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.textPrimary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Membre Pro',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }
}
