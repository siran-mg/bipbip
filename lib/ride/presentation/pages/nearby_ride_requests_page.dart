import 'package:flutter/material.dart';
import 'package:ndao/ride/domain/providers/ride_request_provider.dart';
import 'package:ndao/ride/presentation/components/ride_request_item.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:provider/provider.dart';

/// A page that displays nearby ride requests for drivers
class NearbyRideRequestsPage extends StatefulWidget {
  /// Creates a new NearbyRideRequestsPage
  const NearbyRideRequestsPage({super.key});

  @override
  State<NearbyRideRequestsPage> createState() => _NearbyRideRequestsPageState();
}

class _NearbyRideRequestsPageState extends State<NearbyRideRequestsPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Schedule the ride request loading for after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadNearbyRideRequests();
      }
    });
  }

  Future<void> _loadNearbyRideRequests() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the provider before any async operations
      final rideRequestProvider =
          Provider.of<RideRequestProvider>(context, listen: false);

      // Check if still mounted after getting the provider
      if (!mounted) return;

      // Subscribe to ride request updates
      rideRequestProvider.subscribeToRideRequests();

      // Load nearby ride requests
      await rideRequestProvider.loadNearbyRideRequests();
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error loading nearby ride requests: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes de course'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNearbyRideRequests,
        child: Consumer2<RideRequestProvider, GetCurrentUserInteractor>(
          builder: (context, rideRequestProvider, getCurrentUserInteractor, _) {
            return FutureBuilder(
              future: getCurrentUserInteractor.execute(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erreur: ${snapshot.error}'),
                  );
                }

                final currentUser = snapshot.data;
                if (currentUser == null || !currentUser.isDriver) {
                  return const Center(
                    child: Text('Vous devez être un chauffeur pour voir les demandes'),
                  );
                }

                final driverDetails = currentUser.driverDetails;
                if (driverDetails == null) {
                  return const Center(
                    child: Text('Informations de chauffeur non disponibles'),
                  );
                }

                final nearbyRideRequests = rideRequestProvider.nearbyRideRequests;

                if (_isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (nearbyRideRequests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucune demande de course à proximité',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadNearbyRideRequests,
                          child: const Text('Actualiser'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: nearbyRideRequests.length,
                  itemBuilder: (context, index) {
                    final rideRequest = nearbyRideRequests[index];
                    return RideRequestItem(
                      rideRequest: rideRequest,
                      driverId: currentUser.id,
                      driverLatitude: driverDetails.currentLatitude ?? 0,
                      driverLongitude: driverDetails.currentLongitude ?? 0,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
