import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ndao/user/domain/interactors/upload_profile_photo_interactor.dart';
import 'package:provider/provider.dart';

/// A widget for picking and uploading profile photos
class ProfilePhotoPicker extends StatefulWidget {
  /// The current profile photo URL
  final String? currentPhotoUrl;

  /// The user ID
  final String userId;

  /// Whether this is for a driver (true) or client (false)
  final bool isDriver;

  /// Callback when photo is updated
  final Function(String photoUrl)? onPhotoUpdated;

  /// Creates a new ProfilePhotoPicker
  const ProfilePhotoPicker({
    super.key,
    this.currentPhotoUrl,
    required this.userId,
    required this.isDriver,
    this.onPhotoUpdated,
  });

  @override
  State<ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<ProfilePhotoPicker> {
  bool _isLoading = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _photoUrl = widget.currentPhotoUrl;
  }

  Future<void> _pickAndUploadPhoto() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isLoading = true;
      });

      if (!mounted) return;
      final uploadInteractor =
          Provider.of<UploadProfilePhotoInteractor>(context, listen: false);

      final File imageFile = File(image.path);
      String newPhotoUrl;

      if (widget.isDriver) {
        newPhotoUrl =
            await uploadInteractor.executeForDriver(widget.userId, imageFile);
      } else {
        newPhotoUrl =
            await uploadInteractor.executeForClient(widget.userId, imageFile);
      }

      setState(() {
        _photoUrl = newPhotoUrl;
        _isLoading = false;
      });

      if (widget.onPhotoUpdated != null) {
        widget.onPhotoUpdated!(newPhotoUrl);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil mise à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                image: _photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(_photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _photoUrl == null
                  ? Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey.shade400,
                    )
                  : null,
            ),
            _isLoading
                ? const CircularProgressIndicator()
                : Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      onPressed: _pickAndUploadPhoto,
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Photo de profil',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Appuyez sur l\'icône de caméra pour changer votre photo',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
