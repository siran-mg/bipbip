import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/presentation/components/profile/info_row.dart';

/// Client section component
class ClientSection extends StatelessWidget {
  /// The client details
  final ClientDetails? clientDetails;

  /// Creates a new ClientSection
  const ClientSection({
    super.key,
    required this.clientDetails,
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
              'Profil Client',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (clientDetails?.rating != null)
              InfoRow(
                icon: Icons.star,
                label: 'Note',
                value: '${clientDetails!.rating!.toStringAsFixed(1)}/5.0',
              ),
            if (clientDetails?.rating == null)
              const Text('Aucune note pour le moment'),
          ],
        ),
      ),
    );
  }
}
