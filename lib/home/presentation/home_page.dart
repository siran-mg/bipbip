import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/routes/app_routes.dart';
import 'package:ndao/home/presentation/components/available_drivers_list.dart';
import 'package:ndao/home/presentation/components/nearby_drivers_map.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/ride/presentation/components/create_ride_request_form.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:ndao/user/presentation/pages/favorite_drivers_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _isMapVisible = false;
  String _currentLocation = 'Chargement...';
  late TabController _tabController;
  bool _isClient = false;
  bool _isDriver = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Schedule the location loading for after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCurrentLocation();
        _loadUserInfo();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    if (!mounted) return;

    try {
      final getCurrentUserInteractor =
          Provider.of<GetCurrentUserInteractor>(context, listen: false);

      final currentUser = await getCurrentUserInteractor.execute();

      if (mounted && currentUser != null) {
        setState(() {
          _isClient = currentUser.isClient;
          _isDriver = currentUser.isDriver;
        });
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    }
  }

  Future<void> _loadCurrentLocation() async {
    if (!mounted) return;

    try {
      // Get the provider before any async operations
      final locatorProvider =
          Provider.of<LocatorProvider>(context, listen: false);

      // Check if still mounted after getting the provider
      if (!mounted) return;

      final position = await locatorProvider.getCurrentPosition();

      // Check if still mounted after the async operation
      if (!mounted) return;

      final address = await locatorProvider.getAddressFromPosition(position);

      // Check if still mounted after the async operation
      if (!mounted) return;

      setState(() {
        _currentLocation = address ?? 'Position indéterminée';
      });
    } catch (e) {
      // Check if still mounted after the error
      if (!mounted) return;

      setState(() {
        _currentLocation = 'Position indisponible';
      });
    }
  }

  void _toggleMapView() {
    setState(() {
      _isMapVisible = !_isMapVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.location_on, size: 14),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _currentLocation,
                style: TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Favorites button
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                tooltip: 'Chauffeurs favoris',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoriteDriversPage(),
                    ),
                  );
                },
              ),
            ),
          ),
          // Ride requests button for drivers
          if (_isDriver)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.blue),
                  tooltip: 'Demandes de course',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.nearbyRideRequests);
                  },
                ),
              ),
            ),
          // Client ride history button
          if (_isClient)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.purple.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.history, color: Colors.purple),
                  tooltip: 'Mes demandes',
                  padding: const EdgeInsets.all(8.0),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.clientRideRequests);
                  },
                ),
              ),
            ),
          // Toggle map/list view button
          IconButton(
            icon: Icon(_isMapVisible ? Icons.list : Icons.map),
            tooltip: _isMapVisible ? 'Afficher la liste' : 'Afficher la carte',
            onPressed: _toggleMapView,
          ),
        ],
      ),
      body: Column(
        children: [
          // Client ride request form
          if (_isClient)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CreateRideRequestForm(),
            ),
          // Drivers list or map
          Expanded(
            child: _isMapVisible
                ? const NearbyDriversMap()
                : const AvailableDriversList(),
          ),
        ],
      ),
      floatingActionButton: _isMapVisible
          ? null // Hide FAB when map is visible (map has its own buttons)
          : FloatingActionButton(
              onPressed: () {
                _loadCurrentLocation();
                // Refresh driver list
                setState(() {});
              },
              tooltip: 'Actualiser',
              child: const Icon(Icons.refresh),
            ),
    );
  }
}
