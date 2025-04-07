import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/presentation/components/profile/info_row.dart';

/// User information section component
class UserInfoSection extends StatelessWidget {
  /// The user entity
  final UserEntity user;

  /// Creates a new UserInfoSection
  const UserInfoSection({
    super.key,
    required this.user,
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
              'Informations personnelles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InfoRow(
              icon: Icons.email,
              label: 'Email',
              value: user.email,
            ),
            const Divider(),
            InfoRow(
              icon: Icons.phone,
              label: 'Téléphone',
              value: user.phoneNumber,
            ),
          ],
        ),
      ),
    );
  }
}
