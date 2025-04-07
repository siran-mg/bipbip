import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:ndao/user/presentation/components/profile/edit_vehicle_dialog.dart';

/// Vehicle item component
class VehicleItem extends StatelessWidget {
  /// The vehicle entity
  final VehicleEntity vehicle;

  /// The driver ID
  final String driverId;

  /// Callback when vehicle is updated
  final Function(VehicleEntity) onVehicleUpdated;

  /// Creates a new VehicleItem
  const VehicleItem({
    super.key,
    required this.vehicle,
    required this.driverId,
    required this.onVehicleUpdated,
  });

  /// Show the edit vehicle dialog
  Future<void> _showEditDialog(BuildContext context) async {
    final result = await showDialog<VehicleEntity>(
      context: context,
      builder: (context) => EditVehicleDialog(
        vehicle: vehicle,
        driverId: driverId,
      ),
    );

    if (result != null) {
      onVehicleUpdated(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle photo or placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
              image: vehicle.photoUrl != null && !kIsWeb
                  ? DecorationImage(
                      image: NetworkImage(vehicle.photoUrl!),
                      fit: BoxFit.cover,
                      onError: (_, __) {
                        // Handle image loading error
                        return;
                      },
                    )
                  : null,
            ),
            child: vehicle.photoUrl == null
                ? const Icon(
                    Icons.directions_car,
                    size: 40,
                    color: Colors.grey,
                  )
                : null,
          ),

          const SizedBox(width: 16),

          // Vehicle details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${vehicle.brand} ${vehicle.model}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (vehicle.isPrimary)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Principal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Modifier le véhicule',
                      onPressed: () => _showEditDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Type: ${_getVehicleTypeLabel(vehicle.type)}'),
                const SizedBox(height: 4),
                Text('Plaque: ${vehicle.licensePlate}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get a user-friendly label for a vehicle type
  String _getVehicleTypeLabel(String type) {
    switch (type) {
      case 'motorcycle':
        return 'Moto';
      case 'car':
        return 'Voiture';
      case 'bicycle':
        return 'Vélo';
      case 'other':
        return 'Autre';
      default:
        return type; // Return the original type if not recognized
    }
  }
}
