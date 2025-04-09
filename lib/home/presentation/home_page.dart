import 'package:flutter/material.dart';
import 'package:ndao/home/presentation/components/available_drivers_list.dart';
import 'package:ndao/home/presentation/components/search_driver_form.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMapVisible = false;
  String _currentLocation = 'Chargement...';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        title: Row(
          children: [
            Icon(Icons.location_on, size: 18),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _currentLocation,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isMapVisible ? Icons.list : Icons.map),
            onPressed: _toggleMapView,
            tooltip: _isMapVisible ? 'Afficher la liste' : 'Afficher la carte',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'À proximité'),
            Tab(text: 'Rechercher'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Nearby drivers tab
          _isMapVisible
              ? Center(child: Text('Carte des chauffeurs à proximité'))
              : const AvailableDriversList(),

          // Search tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: const SearchDriverForm(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _loadCurrentLocation();
          if (_tabController.index == 0) {
            // Refresh driver list
            setState(() {});
          }
        },
        tooltip: 'Actualiser',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
