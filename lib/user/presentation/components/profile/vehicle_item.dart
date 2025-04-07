import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:ndao/user/domain/interactors/vehicle_interactor.dart';
import 'package:ndao/user/presentation/components/profile/edit_vehicle_dialog.dart';
import 'package:provider/provider.dart';

/// Vehicle item component
class VehicleItem extends StatefulWidget {
  /// The vehicle entity
  final VehicleEntity vehicle;
  
  /// The driver ID
  final String driverId;
  
  /// Callback when vehicle is updated
  final Function(VehicleEntity) onVehicleUpdated;
  
  /// Callback when vehicle is deleted
  final Function(String) onVehicleDeleted;

  /// Creates a new VehicleItem
  const VehicleItem({
    super.key,
    required this.vehicle,
    required this.driverId,
    required this.onVehicleUpdated,
    required this.onVehicleDeleted,
  });
  
  @override
  State<VehicleItem> createState() => _VehicleItemState();
}

class _VehicleItemState extends State<VehicleItem> {
  bool _isDeleting = false;
  
  /// Show the edit vehicle dialog
  Future<void> _showEditDialog(BuildContext context) async {
    final result = await showDialog<VehicleEntity>(
      context: context,
      builder: (context) => EditVehicleDialog(
        vehicle: widget.vehicle,
        driverId: widget.driverId,
      ),
    );
    
    if (result != null) {
      widget.onVehicleUpdated(result);
    }
  }
  
  /// Show a confirmation dialog before deleting the vehicle
  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le véhicule'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le véhicule "${widget.vehicle.brand} ${widget.vehicle.model}" ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _deleteVehicle();
    }
  }
  
  /// Delete the vehicle
  Future<void> _deleteVehicle() async {
    if (_isDeleting) return;
    
    setState(() {
      _isDeleting = true;
    });
    
    try {
      final vehicleInteractor = Provider.of<VehicleInteractor>(
        context,
        listen: false,
      );
      
      await vehicleInteractor.deleteVehicle(widget.vehicle.id);
      
      if (mounted) {
        widget.onVehicleDeleted(widget.vehicle.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
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
              image: widget.vehicle.photoUrl != null && !kIsWeb
                  ? DecorationImage(
                      image: NetworkImage(widget.vehicle.photoUrl!),
                      fit: BoxFit.cover,
                      onError: (_, __) {
                        // Handle image loading error
                        return;
                      },
                    )
                  : null,
            ),
            child: widget.vehicle.photoUrl == null
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
                              '${widget.vehicle.brand} ${widget.vehicle.model}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.vehicle.isPrimary)
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
                    Row(
                      children: [
                        // Edit button
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: 'Modifier le véhicule',
                          onPressed: () => _showEditDialog(context),
                        ),
                        // Delete button
                        IconButton(
                          icon: _isDeleting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.delete, size: 20, color: Colors.red),
                          tooltip: 'Supprimer le véhicule',
                          onPressed: _isDeleting
                              ? null
                              : () => _confirmDelete(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Type: ${_getVehicleTypeLabel(widget.vehicle.type)}'),
                const SizedBox(height: 4),
                Text('Plaque: ${widget.vehicle.licensePlate}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
