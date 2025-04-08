import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ndao/location/domain/entities/position_entity.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:provider/provider.dart';

/// A map view that displays the driver's current location
class DriverMapView extends StatefulWidget {
  /// The driver user entity
  final UserEntity driver;

  /// Whether to track the driver's location in real-time
  final bool trackInRealTime;

  /// Creates a new DriverMapView
  const DriverMapView({
    super.key,
    required this.driver,
    this.trackInRealTime = true,
  });

  @override
  State<DriverMapView> createState() => _DriverMapViewState();
}

class _DriverMapViewState extends State<DriverMapView> {
  /// Controller for the Google Map
  final Completer<GoogleMapController> _controller = Completer();

  /// Current camera position
  CameraPosition? _currentPosition;

  /// Set of markers on the map
  final Set<Marker> _markers = {};

  /// Stream subscription for location updates
  StreamSubscription<PositionEntity>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  /// Initialize the map with the driver's current location
  Future<void> _initializeMap() async {
    // Get the driver's current position from the driver details
    final driverDetails = widget.driver.driverDetails;
    if (driverDetails != null &&
        driverDetails.currentLatitude != null &&
        driverDetails.currentLongitude != null) {
      // Use the driver's stored position
      _updateMapPosition(
        LatLng(
          driverDetails.currentLatitude!,
          driverDetails.currentLongitude!,
        ),
      );
    } else {
      // If no stored position, try to get the current position
      _getCurrentPosition();
    }

    // If tracking in real-time, start listening for position updates
    if (widget.trackInRealTime) {
      _startPositionTracking();
    }
  }

  /// Get the current position from the location provider
  Future<void> _getCurrentPosition() async {
    try {
      final locatorProvider = Provider.of<LocatorProvider>(
        context,
        listen: false,
      );

      final position = await locatorProvider.getCurrentPosition();
      _updateMapPosition(LatLng(position.latitude, position.longitude));
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la récupération de la position: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Start tracking position updates
  Future<void> _startPositionTracking() async {
    try {
      final locatorProvider = Provider.of<LocatorProvider>(
        context,
        listen: false,
      );

      final positionStream = await locatorProvider.startLocationTracking();
      _positionSubscription = positionStream.listen((position) {
        _updateMapPosition(LatLng(position.latitude, position.longitude));
      });
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du suivi de la position: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Update the map position and marker
  void _updateMapPosition(LatLng position) {
    if (!mounted) return;

    setState(() {
      _currentPosition = CameraPosition(
        target: position,
        zoom: 15,
      );

      // Update markers
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('driver_position'),
          position: position,
          infoWindow: InfoWindow(
            title: widget.driver.fullName,
            snippet: 'Position actuelle',
          ),
        ),
      );
    });

    // Move camera to the new position
    _moveCamera();
  }

  /// Move the camera to the current position
  Future<void> _moveCamera() async {
    if (_currentPosition != null && _controller.isCompleted) {
      final controller = await _controller.future;
      controller
          .animateCamera(CameraUpdate.newCameraPosition(_currentPosition!));
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we don't have a position yet, show a loading indicator
    if (_currentPosition == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        // Google Map
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _currentPosition!,
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
        // Recenter button
        Positioned(
          right: 16,
          bottom: 100,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _moveCamera,
            child: const Icon(Icons.my_location, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
