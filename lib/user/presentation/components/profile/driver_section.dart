import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:ndao/user/domain/interactors/update_driver_availability_interactor.dart';
import 'package:ndao/user/presentation/components/profile/add_vehicle_dialog.dart';
import 'package:ndao/user/presentation/components/profile/info_row.dart';
import 'package:ndao/user/presentation/components/profile/vehicles_section.dart';
import 'package:provider/provider.dart';

/// Driver section component
class DriverSection extends StatefulWidget {
  /// The driver details
  final DriverDetails driverDetails;

  /// The user ID
  final String userId;

  /// Callback when driver details are updated
  final Function(DriverDetails) onDriverDetailsUpdated;

  /// Creates a new DriverSection
  const DriverSection({
    super.key,
    required this.driverDetails,
    required this.userId,
    required this.onDriverDetailsUpdated,
  });

  @override
  State<DriverSection> createState() => _DriverSectionState();
}

class _DriverSectionState extends State<DriverSection> {
  bool _isUpdating = false;

  /// Show the add vehicle dialog
  Future<void> _showAddVehicleDialog(BuildContext context) async {
    final result = await showDialog<VehicleEntity>(
      context: context,
      builder: (context) => AddVehicleDialog(
        driverId: widget.userId,
        isFirstVehicle: widget.driverDetails.vehicles.isEmpty,
      ),
    );

    if (result != null) {
      _handleVehicleUpdated(result);
    }
  }

  /// Handle vehicle updates (both edits and additions)
  void _handleVehicleUpdated(VehicleEntity updatedVehicle) {
    // Check if this is a new vehicle or an update to an existing one
    final existingVehicleIndex = widget.driverDetails.vehicles
        .indexWhere((vehicle) => vehicle.id == updatedVehicle.id);

    List<VehicleEntity> updatedVehicles;

    if (existingVehicleIndex >= 0) {
      // Update existing vehicle
      updatedVehicles = widget.driverDetails.vehicles.map((vehicle) {
        if (vehicle.id == updatedVehicle.id) {
          return updatedVehicle;
        }
        return vehicle;
      }).toList();
    } else {
      // Add new vehicle
      updatedVehicles = [...widget.driverDetails.vehicles, updatedVehicle];
    }

    // Update the driver details
    final updatedDriverDetails = widget.driverDetails.copyWith(
      vehicles: updatedVehicles,
    );

    // Notify the parent
    widget.onDriverDetailsUpdated(updatedDriverDetails);
  }

  Future<void> _toggleAvailability() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final interactor = Provider.of<UpdateDriverAvailabilityInteractor>(
          context,
          listen: false);

      // Create updated driver details with toggled availability
      final updatedDriverDetails = widget.driverDetails.copyWith(
        isAvailable: !widget.driverDetails.isAvailable,
      );

      // Update the UI immediately for better user experience
      widget.onDriverDetailsUpdated(updatedDriverDetails);

      // Then update in the backend
      await interactor.execute(widget.userId, updatedDriverDetails.isAvailable);
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur lors de la mise à jour du statut: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Driver details card
        Card(
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
                      'Profil Chauffeur',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Availability toggle
                    _isUpdating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Switch(
                            value: widget.driverDetails.isAvailable,
                            activeColor: Colors.green,
                            onChanged: (_) => _toggleAvailability(),
                          ),
                  ],
                ),
                const SizedBox(height: 16),
                InfoRow(
                  icon: Icons.star,
                  label: 'Note',
                  value: widget.driverDetails.rating != null
                      ? '${widget.driverDetails.rating!.toStringAsFixed(1)}/5.0'
                      : 'Aucune note',
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: InfoRow(
                        icon: Icons.circle,
                        label: 'Statut',
                        value: widget.driverDetails.isAvailable
                            ? 'Disponible'
                            : 'Non disponible',
                        valueColor: widget.driverDetails.isAvailable
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    Tooltip(
                      message: widget.driverDetails.isAvailable
                          ? 'Désactiver la disponibilité'
                          : 'Activer la disponibilité',
                      child: IconButton(
                        icon: Icon(
                          widget.driverDetails.isAvailable
                              ? Icons.toggle_on
                              : Icons.toggle_off,
                          color: widget.driverDetails.isAvailable
                              ? Colors.green
                              : Colors.grey,
                          size: 32,
                        ),
                        onPressed: _isUpdating ? null : _toggleAvailability,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Vehicles section
        if (widget.driverDetails.vehicles.isNotEmpty)
          VehiclesSection(
            vehicles: widget.driverDetails.vehicles,
            driverId: widget.userId,
            onVehicleUpdated: _handleVehicleUpdated,
          )
        else
          // No vehicles yet, show add vehicle card
          Card(
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
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions_car_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Vous n\'avez pas encore de véhicule',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter un véhicule'),
                          onPressed: () => _showAddVehicleDialog(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
