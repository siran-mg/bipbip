import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/presentation/components/profile/edit_user_info_dialog.dart';
import 'package:ndao/user/presentation/components/profile/info_row.dart';

/// User information section component
class UserInfoSection extends StatelessWidget {
  /// The user entity
  final UserEntity user;

  /// Callback when user information is updated
  final Function(UserEntity) onUserUpdated;

  /// Creates a new UserInfoSection
  const UserInfoSection({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  /// Show the edit user info dialog
  Future<void> _showEditDialog(BuildContext context) async {
    final result = await showDialog<UserEntity>(
      context: context,
      builder: (context) => EditUserInfoDialog(user: user),
    );

    if (result != null) {
      onUserUpdated(result);
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
                  'Informations personnelles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Modifier les informations',
                  onPressed: () => _showEditDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InfoRow(
              icon: Icons.person,
              label: 'Nom complet',
              value: user.fullName,
            ),
            const Divider(),
            if (user.email != null && user.email!.isNotEmpty)
              InfoRow(
                icon: Icons.email,
                label: 'Email',
                value: user.email!,
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
