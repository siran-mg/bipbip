import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:ndao/user/presentation/components/profile/add_vehicle_dialog.dart';
import 'package:ndao/user/presentation/components/profile/vehicle_item.dart';

/// Vehicles section component
class VehiclesSection extends StatelessWidget {
  /// The list of vehicles
  final List<VehicleEntity> vehicles;

  /// The driver ID
  final String driverId;

  /// Callback when a vehicle is updated
  final Function(VehicleEntity) onVehicleUpdated;

  /// Callback when a vehicle is deleted
  final Function(String) onVehicleDeleted;

  /// Creates a new VehiclesSection
  const VehiclesSection({
    super.key,
    required this.vehicles,
    required this.driverId,
    required this.onVehicleUpdated,
    required this.onVehicleDeleted,
  });

  /// Show the add vehicle dialog
  Future<void> _showAddVehicleDialog(BuildContext context) async {
    final result = await showDialog<VehicleEntity>(
      context: context,
      builder: (context) => AddVehicleDialog(
        driverId: driverId,
        isFirstVehicle: vehicles.isEmpty,
      ),
    );

    if (result != null) {
      onVehicleUpdated(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Véhicules',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Ajouter un véhicule',
                  onPressed: () => _showAddVehicleDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...vehicles.map((vehicle) => VehicleItem(
                  vehicle: vehicle,
                  driverId: driverId,
                  onVehicleUpdated: onVehicleUpdated,
                  onVehicleDeleted: onVehicleDeleted,
                )),
          ],
        ),
      ),
    );
  }
}
