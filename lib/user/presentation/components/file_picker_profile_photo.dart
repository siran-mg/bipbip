import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ndao/user/domain/interactors/upload_profile_photo_interactor.dart';
import 'package:provider/provider.dart';

/// A widget for picking and uploading profile photos using FilePicker
/// This works consistently across all platforms including web
class FilePickerProfilePhoto extends StatefulWidget {
  /// The current profile photo URL
  final String? currentPhotoUrl;

  /// The user ID
  final String userId;

  /// Callback when photo is updated
  final Function(String photoUrl)? onPhotoUpdated;

  /// Creates a new FilePickerProfilePhoto
  const FilePickerProfilePhoto({
    super.key,
    this.currentPhotoUrl,
    required this.userId,
    this.onPhotoUpdated,
  });

  @override
  State<FilePickerProfilePhoto> createState() => _FilePickerProfilePhotoState();
}

class _FilePickerProfilePhotoState extends State<FilePickerProfilePhoto> {
  bool _isLoading = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _photoUrl = widget.currentPhotoUrl;
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      // Step 1: Pick file using FilePicker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

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
        // For web, we have the bytes directly from FilePicker
        if (file.bytes == null) {
          throw Exception('File bytes are null');
        }

        final bytes = file.bytes!;
        final extension = '.${file.extension?.toLowerCase() ?? 'jpg'}';

        newPhotoUrl = await uploadInteractor.executeWithBytes(
            widget.userId, bytes, extension);
      } else {
        // For mobile/desktop, we have the file path
        if (file.path == null) {
          throw Exception('File path is null');
        }

        final path = file.path!;
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
        widget.onPhotoUpdated!(newPhotoUrl);
      }

      // Step 6: Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil mise à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show a more detailed error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Erreur lors du téléchargement de la photo:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(e.toString(),
                    maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
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
                        fit: BoxFit.contain,
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
