import 'package:flutter/material.dart';
import 'package:ndao/home/presentation/components/available_drivers_list.dart';
import 'package:ndao/home/presentation/components/simple_drivers_map.dart';
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
    _tabController.addListener(_handleTabChange);
    _loadCurrentLocation();
  }

  void _handleTabChange() {
    // Rebuild UI when tab changes to update IndexedStack and FAB visibility
    if (_tabController.indexIsChanging ||
        _tabController.animation!.value != _tabController.index) {
      setState(() {});
    }
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
          // Only show map toggle on the nearby drivers tab
          if (_tabController.index == 0)
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'À proximité'),
            Tab(text: 'Rechercher'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _tabController.index,
        children: [
          // Nearby drivers tab
          _isMapVisible
              ? const SizedBox.expand(
                  child: SimpleDriversMap(),
                )
              : const AvailableDriversList(),

          // Search tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: const SearchDriverForm(),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 1 || _isMapVisible
          ? null // Hide FAB on search tab or when map is visible (map has its own buttons)
          : FloatingActionButton(
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
