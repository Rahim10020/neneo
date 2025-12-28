import 'package:flutter/material.dart';
import 'package:neneo/providers/trip_provider.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import 'widgets/location_input.dart';
import 'widgets/vehicle_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _origin;
  String? _destination;
  VehicleType _selectedVehicle = VehicleType.zemidjan;
  bool _isNightRate = false;

  @override
  void initState() {
    super.initState();
    _checkNightRate();
  }

  void _checkNightRate() {
    final hour = DateTime.now().hour;
    setState(() {
      _isNightRate = hour >= 20 || hour < 6;
    });
  }

  void _onCalculatePrice() async {
    if (_origin == null || _destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // TODO: Get actual coordinates (replace with real geocoding)
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    final trip = await tripProvider.calculateTrip(
      origin: _origin!,
      destination: _destination!,
      vehicleType: _selectedVehicle == VehicleType.zemidjan ? 'moto' : 'taxi',
      originLat: 6.1319, // Placeholder
      originLng: 1.2227,
      destLat: 6.1656,
      destLng: 1.2545,
    );

    if (trip != null) {
      Navigator.pushNamed(context, AppConstants.routeResult, arguments: trip);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  hint: 'tokoin',
                  icon: Icons.radio_button_checked,
                  iconColor: AppColors.error,
                  onChanged: (value) => setState(() => _origin = value),
                ),

                const SizedBox(height: 8),

                // Use current location button
                GestureDetector(
                  onTap: () {
                    // TODO: Implement geolocation
                    setState(() => _origin = 'Ma position actuelle');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.my_location,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Utiliser ma position actuelle',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.swap_vert,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Destination Input
                LocationInput(
                  label: 'DESTINATION',
                  hint: 'Aeroport',
                  icon: Icons.location_on,
                  iconColor: AppColors.success,
                  onChanged: (value) => setState(() => _destination = value),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onCalculatePrice,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Calculer le prix', style: AppTextStyles.button),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.directions_walk,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
