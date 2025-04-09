import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';
import 'package:provider/provider.dart';

class SimpleDriversMap extends StatefulWidget {
  const SimpleDriversMap({super.key});

  @override
  State<SimpleDriversMap> createState() => _SimpleDriversMapState();
}

class _SimpleDriversMapState extends State<SimpleDriversMap> {
  // Default position (Antananarivo)
  static const LatLng _defaultLocation = LatLng(-18.8792, 47.5079);

  // Map controller
  GoogleMapController? _mapController;

  // Markers
  final Set<Marker> _markers = {};

  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load drivers after a short delay to ensure the widget is mounted
    Future.delayed(Duration.zero, _loadDrivers);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadDrivers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userRepository =
          Provider.of<UserRepository>(context, listen: false);
      final drivers = await userRepository.getAvailableDrivers();

      // Add simulated locations for drivers
      _addMarkersForDrivers(drivers);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading drivers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addMarkersForDrivers(List<UserEntity> drivers) {
    // Clear existing markers
    _markers.clear();

    // Add marker for current location
    _markers.add(
      const Marker(
        markerId: MarkerId('my_location'),
        position: _defaultLocation,
        infoWindow: InfoWindow(
          title: 'Ma position',
          snippet: 'Vous êtes ici',
        ),
      ),
    );

    // Add markers for each driver with simulated locations
    for (int i = 0; i < drivers.length; i++) {
      final driver = drivers[i];

      // Generate a position around the default location
      final offset = 0.005 * (i + 1);
      final angle = (i * 45) % 360 * 3.14159 / 180; // Convert to radians

      final latitude = _defaultLocation.latitude + offset * math.sin(angle);
      final longitude = _defaultLocation.longitude + offset * math.cos(angle);

      _markers.add(
        Marker(
          markerId: MarkerId('driver_${driver.id}'),
          position: LatLng(latitude, longitude),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: driver.fullName,
            snippet: driver.driverDetails?.primaryVehicle != null
                ? '${driver.driverDetails!.primaryVehicle!.brand} ${driver.driverDetails!.primaryVehicle!.model}'
                : 'Chauffeur disponible',
          ),
        ),
      );
    }

    setState(() {});

    // Move camera to show all markers
    if (_mapController != null && _markers.isNotEmpty) {
      _mapController!
          .animateCamera(CameraUpdate.newLatLngZoom(_defaultLocation, 14));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a simpler approach with AbsorbPointer to prevent interaction during loading
    return AbsorbPointer(
      absorbing: _isLoading,
      child: Stack(
        children: [
          // The map takes the full size of its container
          SizedBox.expand(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _defaultLocation,
                zoom: 14,
              ),
              markers: _markers,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                });
                // Reload drivers when map is created
                _loadDrivers();
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(76), // 0.3 opacity
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Refresh button
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _loadDrivers,
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }
}
