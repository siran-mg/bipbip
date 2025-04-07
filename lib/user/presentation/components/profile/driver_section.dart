import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/presentation/components/profile/info_row.dart';
import 'package:ndao/user/presentation/components/profile/vehicles_section.dart';

/// Driver section component
class DriverSection extends StatelessWidget {
  /// The driver details
  final DriverDetails driverDetails;

  /// Creates a new DriverSection
  const DriverSection({
    super.key,
    required this.driverDetails,
  });

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
                const Text(
                  'Profil Chauffeur',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                InfoRow(
                  icon: Icons.star,
                  label: 'Note',
                  value: driverDetails.rating != null
                      ? '${driverDetails.rating!.toStringAsFixed(1)}/5.0'
                      : 'Aucune note',
                ),
                const Divider(),
                InfoRow(
                  icon: Icons.circle,
                  label: 'Statut',
                  value: driverDetails.isAvailable ? 'Disponible' : 'Non disponible',
                  valueColor:
                      driverDetails.isAvailable ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Vehicles section
        if (driverDetails.vehicles.isNotEmpty)
          VehiclesSection(vehicles: driverDetails.vehicles),
      ],
    );
  }
}
