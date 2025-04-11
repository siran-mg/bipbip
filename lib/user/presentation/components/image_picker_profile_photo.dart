import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ndao/user/domain/interactors/upload_profile_photo_interactor.dart';
import 'package:provider/provider.dart';

/// A widget for picking and uploading profile photos using ImagePicker
/// This works consistently across all platforms including web
class ImagePickerProfilePhoto extends StatefulWidget {
  /// The current profile photo URL
  final String? currentPhotoUrl;

  /// The user ID
  final String userId;

  /// Callback when photo is updated
  final Function(String photoUrl)? onPhotoUpdated;

  /// Creates a new ImagePickerProfilePhoto
  const ImagePickerProfilePhoto({
    super.key,
    this.currentPhotoUrl,
    required this.userId,
    this.onPhotoUpdated,
  });

  @override
  State<ImagePickerProfilePhoto> createState() => _ImagePickerProfilePhotoState();
}

class _ImagePickerProfilePhotoState extends State<ImagePickerProfilePhoto> {
  bool _isLoading = false;
  String? _photoUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _photoUrl = widget.currentPhotoUrl;
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      // Show a dialog to choose between camera and gallery
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Choisir une source'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.photo_library),
                          SizedBox(width: 10),
                          Text('Galerie'),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(ImageSource.gallery);
                    },
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.photo_camera),
                          SizedBox(width: 10),
                          Text('Caméra'),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(ImageSource.camera);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (source == null) {
        return;
      }

      // Step 1: Pick image using ImagePicker
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      setState(() {
        _isLoading = true;
      });

      if (!mounted) return;

      // Step 2: Get the upload interactor
      final uploadInteractor =
          Provider.of<UploadProfilePhotoInteractor>(context, listen: false);

      // Step 3: Upload the file
      String newPhotoUrl;

      if (kIsWeb) {
        // For web, we need to read the bytes
        final bytes = await pickedFile.readAsBytes();
        final extension = '.${pickedFile.name.split('.').last.toLowerCase()}';

        newPhotoUrl = await uploadInteractor.executeWithBytes(
            widget.userId, bytes, extension);
      } else {
        // For mobile/desktop, we have the file path
        final path = pickedFile.path;
        final imageFile = File(path);

        newPhotoUrl = await uploadInteractor.execute(widget.userId, imageFile);
      }

      // Step 4: Update the UI
      if (!mounted) return;
      setState(() {
        _photoUrl = newPhotoUrl;
        _isLoading = false;
      });

      // Step 5: Call the callback if provided
      if (widget.onPhotoUpdated != null) {
        widget.onPhotoUpdated!(_photoUrl!);
      }
    } catch (e) {
      if (!mounted) return;
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
        GestureDetector(
          onTap: _isLoading ? null : _pickAndUploadPhoto,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                  image: _photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _photoUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      )
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Photo de profil',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
