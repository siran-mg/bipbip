import 'package:flutter/material.dart';
import 'package:ndao/ride/domain/providers/ride_request_provider.dart';
import 'package:ndao/ride/presentation/components/client_ride_request_item.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:provider/provider.dart';

/// A page that displays a client's ride request history
class ClientRideRequestsPage extends StatefulWidget {
  /// Creates a new ClientRideRequestsPage
  const ClientRideRequestsPage({super.key});

  @override
  State<ClientRideRequestsPage> createState() => _ClientRideRequestsPageState();
}

class _ClientRideRequestsPageState extends State<ClientRideRequestsPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Schedule the ride request loading for after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadClientRideRequests();
      }
    });
  }

  Future<void> _loadClientRideRequests() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      final getCurrentUserInteractor =
          Provider.of<GetCurrentUserInteractor>(context, listen: false);
      final currentUser = await getCurrentUserInteractor.execute();

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Get the provider before any async operations
      final rideRequestProvider =
          Provider.of<RideRequestProvider>(context, listen: false);

      // Check if still mounted after getting the provider
      if (!mounted) return;

      // Load client ride requests
      await rideRequestProvider.loadClientRideRequests(currentUser.id);
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error loading client ride requests: $e');
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
        title: const Text('Mes demandes de course'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadClientRideRequests,
        child: Consumer<RideRequestProvider>(
          builder: (context, rideRequestProvider, _) {
            final clientRideRequests = rideRequestProvider.clientRideRequests;

            if (_isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (clientRideRequests.isEmpty) {
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
                      'Vous n\'avez pas encore de demandes de course',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadClientRideRequests,
                      child: const Text('Actualiser'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: clientRideRequests.length,
              itemBuilder: (context, index) {
                final rideRequest = clientRideRequests[index];
                return ClientRideRequestItem(
                  rideRequest: rideRequest,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
