import 'package:flutter/material.dart';
import 'package:ndao/home/presentation/components/available_drivers_list.dart';
import 'package:ndao/home/presentation/components/nearby_drivers_map.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
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
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final locatorProvider =
          Provider.of<LocatorProvider>(context, listen: false);
      final position = await locatorProvider.getCurrentPosition();
      final address = await locatorProvider.getAddressFromPosition(position);

      if (mounted) {
        setState(() {
          _currentLocation = address ?? 'Position indéterminée';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentLocation = 'Position indisponible';
        });
      }
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chauffeurs à proximité',
                style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[300]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _currentLocation,
                    style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Map toggle button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              icon: Icon(_isMapVisible ? Icons.list : Icons.map),
              label: Text(_isMapVisible ? 'Liste' : 'Carte'),
              onPressed: _toggleMapView,
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withAlpha(128),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
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
