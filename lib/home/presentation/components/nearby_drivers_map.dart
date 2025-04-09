import 'dart:async';
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
  final Completer<GoogleMapController> _controller = Completer();

  // Default position (Antananarivo)
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(-18.8792, 47.5079),
    zoom: 13,
  );

  // Current user position
  CameraPosition? _currentPosition;

  // Markers for drivers
  final Set<Marker> _markers = {};

  // Loading state
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize map with a short delay to ensure the widget is properly mounted
    Future.delayed(Duration.zero, _initializeMap);
  }

  Future<void> _initializeMap() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Set a timeout to ensure loading state doesn't get stuck
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Délai d\'attente dépassé. Veuillez réessayer.';
        });
      }
    });

    try {
      // Get current location
      await _getCurrentLocation();

      // Load drivers
      await _loadDrivers();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors du chargement de la carte: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locatorProvider =
          Provider.of<LocatorProvider>(context, listen: false);
      final position = await locatorProvider.getCurrentPosition();

      _currentPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15,
      );

      // Move camera to current position
      if (_controller.isCompleted) {
        final controller = await _controller.future;
        controller
            .animateCamera(CameraUpdate.newCameraPosition(_currentPosition!));
      }
    } catch (e) {
      // If we can't get current location, use default
      _currentPosition = _defaultPosition;

      // Don't rethrow - we'll use the default position instead
      // In a production app, use a proper logging framework
      debugPrint('Could not get current location: $e');
    }
  }

  Future<void> _loadDrivers() async {
    try {
      final userRepository =
          Provider.of<UserRepository>(context, listen: false);
      final drivers = await userRepository.getAvailableDrivers();

      // Add simulated locations for drivers that don't have locations
      // This is just for demonstration purposes
      final driversWithLocations = _addSimulatedLocations(drivers);

      _updateMarkers(driversWithLocations);
    } catch (e) {
      // Just log the error and continue with empty markers
      // This prevents the map from failing to load if we can't get drivers
      // In a production app, use a proper logging framework
      debugPrint('Could not load drivers: $e');
      _updateMarkers([]);
    }
  }

  List<UserEntity> _addSimulatedLocations(List<UserEntity> drivers) {
    // Only proceed if we have a current position
    if (_currentPosition == null) return drivers;

    final baseLatitude = _currentPosition!.target.latitude;
    final baseLongitude = _currentPosition!.target.longitude;

    // Create a new list with simulated locations
    return drivers
        .asMap()
        .map((index, driver) {
          // Skip if driver already has location
          if (driver.driverDetails?.currentLatitude != null &&
              driver.driverDetails?.currentLongitude != null) {
            return MapEntry(index, driver);
          }

          // Use driver id and index to create deterministic but different offsets
          // This ensures each driver gets a unique but consistent position
          final seed = driver.id.hashCode + index;
          final random = seed * 31 % 1000;

          // Generate a random offset (between 0.001 and 0.01 degrees, roughly 100m to 1km)
          // Use sine and cosine to distribute drivers in a circle around the user
          final distance = 0.001 + (random % 9) / 1000.0; // 0.001 to 0.01
          final angle = (random % 360) * 3.14159 / 180.0; // 0 to 2π in radians

          final latOffset = distance * math.sin(angle);
          final lngOffset = distance * math.cos(angle);

          // Create a new driver details with location
          final newDriverDetails = driver.driverDetails?.copyWith(
                currentLatitude: baseLatitude + latOffset,
                currentLongitude: baseLongitude + lngOffset,
              ) ??
              DriverDetails(
                isAvailable: true,
                currentLatitude: baseLatitude + latOffset,
                currentLongitude: baseLongitude + lngOffset,
                vehicles: [],
              );

          // Return a new driver with the updated details
          return MapEntry(
              index, driver.copyWith(driverDetails: newDriverDetails));
        })
        .values
        .toList();
  }

  void _updateMarkers(List<UserEntity> drivers) {
    final newMarkers = <Marker>{};

    // Add marker for current user position if available
    if (_currentPosition != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition!.target,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Ma position',
            snippet: 'Vous êtes ici',
          ),
        ),
      );
    }

    // Add markers for each driver
    for (final driver in drivers) {
      if (driver.driverDetails?.currentLatitude != null &&
          driver.driverDetails?.currentLongitude != null) {
        newMarkers.add(
          Marker(
            markerId: MarkerId('driver_${driver.id}'),
            position: LatLng(
              driver.driverDetails!.currentLatitude!,
              driver.driverDetails!.currentLongitude!,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: driver.fullName,
              snippet: driver.driverDetails?.primaryVehicle != null
                  ? '${driver.driverDetails!.primaryVehicle!.brand} ${driver.driverDetails!.primaryVehicle!.model}'
                  : 'Chauffeur disponible',
              onTap: () {
                _showDriverDetails(driver);
              },
            ),
          ),
        );
      }
    }

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }

  void _showDriverDetails(UserEntity driver) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: driver.profilePictureUrl != null
                    ? NetworkImage(driver.profilePictureUrl!)
                    : null,
                child: driver.profilePictureUrl == null
                    ? Text(
                        driver.givenName[0] + driver.familyName[0],
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              title: Text(driver.fullName),
              subtitle: Text(driver.driverDetails?.primaryVehicle != null
                  ? '${driver.driverDetails!.primaryVehicle!.brand} ${driver.driverDetails!.primaryVehicle!.model}'
                  : 'Véhicule inconnu'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star,
                      color: Theme.of(context).colorScheme.secondary, size: 16),
                  const SizedBox(width: 4),
                  Text(driver.driverDetails?.rating?.toString() ?? 'N/A'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.phone,
                  label: 'Appeler',
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Appel à ${driver.phoneNumber}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _ActionButton(
                  icon: Icons.message,
                  label: 'SMS',
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('SMS à ${driver.phoneNumber}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _ActionButton(
                  icon: Icons.directions,
                  label: 'Itinéraire',
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Affichage de l\'itinéraire'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement de la carte...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _initializeMap,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Use a simple map with minimal features to ensure it loads quickly
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _currentPosition ?? _defaultPosition,
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
          liteModeEnabled:
              false, // Set to true for even better performance, but less features
          onMapCreated: (GoogleMapController controller) {
            // Complete the controller future
            if (!_controller.isCompleted) {
              _controller.complete(controller);
            }

            // If we already have a position, move camera to it
            if (_currentPosition != null) {
              controller.animateCamera(
                  CameraUpdate.newCameraPosition(_currentPosition!));
            }

            // Ensure loading is set to false when map is created
            if (mounted && _isLoading) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'refresh_map',
                mini: true,
                onPressed: _initializeMap,
                child: const Icon(Icons.refresh),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'my_location',
                onPressed: () async {
                  await _getCurrentLocation();
                  if (_currentPosition != null && _controller.isCompleted) {
                    final controller = await _controller.future;
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(_currentPosition!),
                    );
                  }
                },
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
