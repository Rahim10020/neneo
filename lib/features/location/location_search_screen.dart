import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/trip_provider.dart';
import '../../services/location_service.dart';
import 'widgets/location_suggestion_tile.dart';
import 'widgets/location_search_bar.dart';
import 'widgets/current_location_button.dart';
import 'widgets/no_results_state.dart';

class LocationSearchScreen extends StatefulWidget {
  final String title;
  final PlaceResult? initialPlace;

  const LocationSearchScreen({
    super.key,
    required this.title,
    this.initialPlace,
  });

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<PlaceResult> _suggestions = [];
  List<PlaceResult> _popularPlaces = [];
  bool _isSearching = false;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadPopularPlaces();
    _searchController.addListener(_onSearchChanged);

    // Auto-focus le champ de recherche
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _loadPopularPlaces() {
    final locationService = LocationService();
    setState(() {
      _popularPlaces = locationService.getPopularPlaces();
      _suggestions = _popularPlaces;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _suggestions = _popularPlaces;
      });
      return;
    }

    if (query.length < 2) return;

    _searchPlaces(query);
  }

  Future<void> _searchPlaces(String query) async {
    setState(() => _isSearching = true);

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final results = await tripProvider.searchPlaces(query);

    // Filtrer aussi les lieux populaires
    final filteredPopular = _popularPlaces.where((place) {
      return place.displayName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // Combiner les résultats
    final combined = <PlaceResult>[...filteredPopular, ...results];

    // Enlever les doublons
    final seen = <String>{};
    final unique = combined.where((place) {
      final key = '${place.lat},${place.lng}';
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();

    setState(() {
      _suggestions = unique;
      _isSearching = false;
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final location = await tripProvider.getCurrentLocation();

    setState(() => _isGettingLocation = false);

    if (location != null) {
      if (!mounted) return;
      Navigator.pop(context, location);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'obtenir votre position'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _onPlaceSelected(PlaceResult place) {
    Navigator.pop(context, place);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: AppTextStyles.h3.copyWith(fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          LocationSearchBar(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onClear: () {
              _searchController.clear();
              setState(() {
                _suggestions = _popularPlaces;
              });
            },
          ),

          // Bouton position actuelle
          CurrentLocationButton(
            isGettingLocation: _isGettingLocation,
            onTap: _useCurrentLocation,
          ),

          const Divider(height: 1, color: AppColors.gray300),

          // Liste de suggestions
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _suggestions.isEmpty
                ? const NoResultsState()
                : ListView.builder(
                    itemCount: _suggestions.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final place = _suggestions[index];
                      return LocationSuggestionTile(
                        place: place,
                        onTap: () => _onPlaceSelected(place),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
