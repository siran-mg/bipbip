import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/presentation/components/file_picker_profile_photo.dart';

/// Profile header component with photo and user information
class ProfileHeader extends StatelessWidget {
  /// The user entity
  final UserEntity user;
  
  /// Callback when the profile photo is updated
  final Function(String) onPhotoUpdated;

  /// Creates a new ProfileHeader
  const ProfileHeader({
    super.key,
    required this.user,
    required this.onPhotoUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Profile photo
          FilePickerProfilePhoto(
            userId: user.id,
            currentPhotoUrl: user.profilePictureUrl,
            onPhotoUpdated: onPhotoUpdated,
          ),

          const SizedBox(height: 16),

          // User name
          Text(
            user.fullName,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          // User roles
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: user.roles.map((role) {
              return Chip(
                label: Text(
                  role == 'client' ? 'Client' : 'Chauffeur',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
