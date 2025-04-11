import 'package:flutter/material.dart';
import 'package:ndao/location/domain/utils/location_utils.dart';
import 'package:ndao/ride/domain/entities/ride_request_entity.dart';
import 'package:ndao/ride/domain/providers/ride_request_provider.dart';
import 'package:provider/provider.dart';

/// A widget that displays a ride request
class RideRequestItem extends StatefulWidget {
  /// The ride request to display
  final RideRequestEntity rideRequest;

  /// The driver's ID
  final String driverId;

  /// The driver's latitude
  final double driverLatitude;

  /// The driver's longitude
  final double driverLongitude;

  /// Creates a new RideRequestItem
  const RideRequestItem({
    super.key,
    required this.rideRequest,
    required this.driverId,
    required this.driverLatitude,
    required this.driverLongitude,
  });

  @override
  State<RideRequestItem> createState() => _RideRequestItemState();
}

class _RideRequestItemState extends State<RideRequestItem> {
  bool _isAccepting = false;
  bool _isRejecting = false;

  @override
  Widget build(BuildContext context) {
    // Calculate distance from driver to pickup
    final distance = LocationUtils.calculateDistance(
      widget.driverLatitude,
      widget.driverLongitude,
      widget.rideRequest.pickupLatitude,
      widget.rideRequest.pickupLongitude,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.rideRequest.destinationName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '${widget.rideRequest.budget.toStringAsFixed(0)} Ar',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Distance: ${distance.toStringAsFixed(1)} km',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isRejecting || _isAccepting
                      ? null
                      : () => _rejectRideRequest(),
                  child: _isRejecting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Refuser'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isAccepting || _isRejecting
                      ? null
                      : () => _acceptRideRequest(),
                  child: _isAccepting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Accepter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptRideRequest() async {
    setState(() {
      _isAccepting = true;
    });

    try {
      final rideRequestProvider =
          Provider.of<RideRequestProvider>(context, listen: false);
      await rideRequestProvider.acceptRideRequest(
        requestId: widget.rideRequest.id,
        driverId: widget.driverId,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande acceptée!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAccepting = false;
        });
      }
    }
  }

  Future<void> _rejectRideRequest() async {
    setState(() {
      _isRejecting = true;
    });

    try {
      final rideRequestProvider =
          Provider.of<RideRequestProvider>(context, listen: false);
      await rideRequestProvider.rejectRideRequest(
        requestId: widget.rideRequest.id,
        driverId: widget.driverId,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande refusée'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRejecting = false;
        });
      }
    }
  }
}
