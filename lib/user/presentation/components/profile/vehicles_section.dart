import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:ndao/user/presentation/components/profile/vehicle_item.dart';

/// Vehicles section component
class VehiclesSection extends StatelessWidget {
  /// The list of vehicles
  final List<VehicleEntity> vehicles;

  /// The driver ID
  final String driverId;

  /// Callback when a vehicle is updated
  final Function(VehicleEntity) onVehicleUpdated;

  /// Creates a new VehiclesSection
  const VehiclesSection({
    super.key,
    required this.vehicles,
    required this.driverId,
    required this.onVehicleUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Véhicules',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...vehicles.map((vehicle) => VehicleItem(
                  vehicle: vehicle,
                  driverId: driverId,
                  onVehicleUpdated: onVehicleUpdated,
                )),
          ],
        ),
      ),
    );
  }
}
