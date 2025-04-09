import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';
import 'package:provider/provider.dart';

class NearbyDriversMap extends StatefulWidget {
  const NearbyDriversMap({super.key});

  @override
  State<NearbyDriversMap> createState() => _NearbyDriversMapState();
}

class _NearbyDriversMapState extends State<NearbyDriversMap> {
  // Default position (Antananarivo)
  static const LatLng _defaultLocation = LatLng(-18.8792, 47.5079);

  // Map controller
  GoogleMapController? _mapController;

  // Markers
  final Set<Marker> _markers = {};

  // Loading state
  bool _isLoading = true;

  // User's current location
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    // Load drivers after a short delay to ensure the widget is mounted
    Future.delayed(Duration.zero, () {
      _getUserLocation();
      _loadDrivers();
    });
  }

  Future<void> _getUserLocation() async {
    try {
      final locatorProvider =
          Provider.of<LocatorProvider>(context, listen: false);
      final position = await locatorProvider.getCurrentPosition();

      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          debugPrint('Got user location: $_userLocation');
        });

        // Update map camera if controller is ready
        if (_mapController != null && _userLocation != null) {
          _mapController!
              .animateCamera(CameraUpdate.newLatLngZoom(_userLocation!, 14));
        }
      }
    } catch (e) {
      debugPrint('Error getting user location: $e');
      // Continue with default location
    }
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

    // Add marker for current location (use real location if available)
    final userPosition = _userLocation ?? _defaultLocation;
    _markers.add(
      Marker(
        markerId: const MarkerId('my_location'),
        position: userPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'Ma position',
          snippet: 'Vous êtes ici',
        ),
      ),
    );

    debugPrint('Added user location marker at: $userPosition');

    // Track if we have any real driver locations
    bool hasRealLocations = false;
    LatLng? boundsCenter;

    // Add markers for each driver
    for (int i = 0; i < drivers.length; i++) {
      final driver = drivers[i];
      late LatLng driverPosition;

      // Check if driver has real location data
      if (driver.driverDetails?.currentLatitude != null &&
          driver.driverDetails?.currentLongitude != null) {
        // Use real location data
        driverPosition = LatLng(
          driver.driverDetails!.currentLatitude!,
          driver.driverDetails!.currentLongitude!,
        );
        hasRealLocations = true;
        boundsCenter = driverPosition; // Use the last real location as center
        debugPrint(
            'Using real location for driver ${driver.fullName}: $driverPosition');
      } else {
        // Generate a simulated position around the default location
        final offset = 0.005 * (i + 1);
        final angle = (i * 45) % 360 * 3.14159 / 180; // Convert to radians

        final latitude = _defaultLocation.latitude + offset * math.sin(angle);
        final longitude = _defaultLocation.longitude + offset * math.cos(angle);

        driverPosition = LatLng(latitude, longitude);
        debugPrint(
            'Using simulated location for driver ${driver.fullName}: $driverPosition');
      }

      // Add the marker
      _markers.add(
        Marker(
          markerId: MarkerId('driver_${driver.id}'),
          position: driverPosition,
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
      // Priority for centering the map:
      // 1. Real driver location if available
      // 2. User's real location if available
      // 3. Default location as last resort
      LatLng center;
      String centerType;

      if (hasRealLocations) {
        center = boundsCenter!;
        centerType = 'driver\'s real location';
      } else if (_userLocation != null) {
        center = _userLocation!;
        centerType = 'user\'s real location';
      } else {
        center = _defaultLocation;
        centerType = 'default location';
      }

      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(center, 14));
      debugPrint('Centering map on $centerType: $center');
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
              myLocationEnabled: true, // Show blue dot for user location
              myLocationButtonEnabled: false, // We have our own button
              zoomControlsEnabled: true,
              compassEnabled: true,
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

          // Action buttons
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Refresh button
                FloatingActionButton.small(
                  heroTag: 'refresh_map',
                  onPressed: _loadDrivers,
                  tooltip: 'Actualiser',
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(height: 8),
                // My location button
                FloatingActionButton(
                  heroTag: 'my_location',
                  onPressed: () {
                    _getUserLocation();
                    if (_userLocation != null && _mapController != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(_userLocation!, 15),
                      );
                    }
                  },
                  tooltip: 'Ma position',
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
