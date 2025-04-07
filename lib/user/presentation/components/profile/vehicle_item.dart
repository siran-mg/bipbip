import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';

/// Vehicle item component
class VehicleItem extends StatelessWidget {
  /// The vehicle entity
  final VehicleEntity vehicle;

  /// Creates a new VehicleItem
  const VehicleItem({
    super.key,
    required this.vehicle,
  });

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
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
