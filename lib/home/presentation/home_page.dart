import 'package:flutter/material.dart';
import 'package:ndao/home/presentation/components/available_drivers_list.dart';
import 'package:ndao/home/presentation/components/nearby_drivers_map.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/user/presentation/pages/favorite_drivers_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMapVisible = false;
  String _currentLocation = 'Chargement...';

  @override
  void initState() {
    super.initState();
    // Schedule the location loading for after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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
          IconButton(
            icon: const Icon(Icons.favorite),
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
          // Toggle map/list view button
          IconButton(
            icon: Icon(_isMapVisible ? Icons.list : Icons.map),
            tooltip: _isMapVisible ? 'Afficher la liste' : 'Afficher la carte',
            onPressed: _toggleMapView,
          ),
        ],
      ),
      body: _isMapVisible
          ? const SizedBox.expand(
              child: NearbyDriversMap(),
            )
          : const AvailableDriversList(),
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
