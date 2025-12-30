import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/trip_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/location_service.dart';
import '../location/location_search_screen.dart';
import 'widgets/location_button.dart';
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

  // Loading states
  bool _isGettingLocation = false;

  // Permission states
  bool _hasRequestedPermission = false;
  bool _locationPermissionDenied = false;

  // Night rate detection
  bool _isNightRate = false;

  @override
  void initState() {
    super.initState();
    _checkNightRate();
    _loadUserPreferences();
    // Demander la permission après le build initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermissionWithDialog();
    });
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

  Future<void> _requestLocationPermissionWithDialog() async {
    if (_hasRequestedPermission) return;

    final locationService = LocationService();

    // Vérifier d'abord si le service GPS est activé
    final serviceEnabled = await locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      _showLocationServiceDisabledDialog();
      return;
    }

    // Vérifier le statut actuel de la permission
    final permission = await locationService.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      // Permission refusée définitivement
      if (!mounted) return;
      _showPermissionDeniedForeverDialog();
      return;
    }

    if (permission == LocationPermission.denied) {
      // Montrer un dialogue explicatif avant de demander
      if (!mounted) return;
      final shouldRequest = await _showPermissionExplanationDialog();

      if (shouldRequest == true) {
        setState(() => _hasRequestedPermission = true);
        await _requestAndUseLocation();
      } else {
        setState(() {
          _hasRequestedPermission = true;
          _locationPermissionDenied = true;
        });
      }
    } else {
      // Permission déjà accordée
      setState(() => _hasRequestedPermission = true);
      await _initializeOriginWithCurrentLocation();
    }
  }

  Future<bool?> _showPermissionExplanationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_on, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              'Localisation',
              style: AppTextStyles.h3.copyWith(fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'neneo? souhaite accéder à votre position pour détecter automatiquement votre point de départ.\n\nVous pouvez aussi sélectionner manuellement votre position si vous refusez.',
          style: AppTextStyles.bodyLarge,
        ),
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Refuser',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'Autoriser',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_off, color: AppColors.error),
            const SizedBox(width: 12),
            Text(
              'GPS désactivé',
              style: AppTextStyles.h3.copyWith(fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Veuillez activer le GPS de votre appareil pour utiliser la détection automatique de position.\n\nVous pouvez continuer en sélectionnant manuellement votre point de départ.',
          style: AppTextStyles.bodyLarge,
        ),
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _hasRequestedPermission = true;
                _locationPermissionDenied = true;
              });
            },
            child: Text(
              'Continuer sans GPS',
              style: AppTextStyles.button.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_off, color: AppColors.error),
            const SizedBox(width: 12),
            Text(
              'Permission refusée',
              style: AppTextStyles.h3.copyWith(fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'L\'accès à la localisation a été refusé définitivement.\n\nPour l\'activer, allez dans les paramètres de l\'application.',
          style: AppTextStyles.bodyLarge,
        ),
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _hasRequestedPermission = true;
                _locationPermissionDenied = true;
              });
            },
            child: Text(
              'Continuer sans',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await LocationService().openAppSettings();
              setState(() {
                _hasRequestedPermission = true;
                _locationPermissionDenied = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'Ouvrir paramètres',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestAndUseLocation() async {
    final locationService = LocationService();
    final permission = await locationService.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _locationPermissionDenied = true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission de localisation refusée. Vous pouvez sélectionner votre position manuellement.'),
          backgroundColor: AppColors.warning,
        ),
      );
    } else {
      await _initializeOriginWithCurrentLocation();
    }
  }

  Future<void> _initializeOriginWithCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final location = await tripProvider.getCurrentLocation();

    if (location != null) {
      setState(() {
        _originPlace = location;
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'obtenir votre position. Sélectionnez manuellement votre point de départ.'),
          backgroundColor: AppColors.warning,
        ),
      );
    }

    setState(() => _isGettingLocation = false);
  }

  Future<void> _selectOrigin() async {
    final result = await Navigator.push<PlaceResult>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSearchScreen(
          title: 'Point de départ',
          initialPlace: _originPlace,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _originPlace = result;
      });
    }
  }

  Future<void> _selectDestination() async {
    final result = await Navigator.push<PlaceResult>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSearchScreen(
          title: 'Destination',
          initialPlace: _destinationPlace,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _destinationPlace = result;
      });
    }
  }

  void _swapLocations() {
    if (_originPlace == null && _destinationPlace == null) return;

    setState(() {
      final temp = _originPlace;
      _originPlace = _destinationPlace;
      _destinationPlace = temp;
    });
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final canCalculate = _originPlace != null && _destinationPlace != null;

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
                    Text(AppConstants.appName, style: AppTextStyles.brandLogoSmall),
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

                // Origin Button
                if (_isGettingLocation)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Détection de votre position...',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  LocationButton(
                    label: 'POINT DE DEPART',
                    selectedPlace: _originPlace,
                    icon: Icons.radio_button_checked,
                    iconColor: AppColors.error,
                    onTap: _selectOrigin,
                  ),

                const SizedBox(height: 16),

                // Swap button
                Center(
                  child: GestureDetector(
                    onTap: _swapLocations,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.gray300,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.swap_vert,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Destination Button
                LocationButton(
                  label: 'DESTINATION',
                  selectedPlace: _destinationPlace,
                  icon: Icons.location_on,
                  iconColor: AppColors.success,
                  onTap: _selectDestination,
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
                        onPressed: canCalculate && !tripProvider.isCalculating
                            ? _onCalculatePrice
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: canCalculate
                              ? AppColors.primary
                              : AppColors.gray300,
                          disabledBackgroundColor: AppColors.gray300,
                        ),
                        child: tripProvider.isCalculating
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textOnPrimary,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Calculer le prix',
                                    style: AppTextStyles.button.copyWith(
                                      color: canCalculate
                                          ? AppColors.textPrimary
                                          : AppColors.gray500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.calculate,
                                    size: 20,
                                    color: canCalculate
                                        ? AppColors.textPrimary
                                        : AppColors.gray500,
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Distance estimate if both places selected
                if (canCalculate)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cliquez sur "Calculer le prix" pour obtenir une estimation',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Pro badge (if user is Pro)
                if (userProvider.isPro) ...[
                  const SizedBox(height: 24),
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
}
