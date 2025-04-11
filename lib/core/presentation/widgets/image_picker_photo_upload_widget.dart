import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget for uploading and displaying a photo using ImagePicker
/// This works consistently across all platforms including web
class ImagePickerPhotoUploadWidget extends StatelessWidget {
  /// The current photo file (for mobile/desktop)
  final File? photoFile;

  /// The current photo bytes (for web)
  final Uint8List? photoBytes;

  /// The placeholder icon
  final IconData placeholderIcon;

  /// The label text
  final String labelText;

  /// Callback when photo is picked (for mobile/desktop)
  final Function(File)? onFilePhotoPicked;

  /// Callback when photo is picked (for web)
  final Function(Uint8List, String)? onBytesPhotoPicked;

  /// Creates a new ImagePickerPhotoUploadWidget
  const ImagePickerPhotoUploadWidget({
    super.key,
    this.photoFile,
    this.photoBytes,
    this.placeholderIcon = Icons.person,
    required this.labelText,
    this.onFilePhotoPicked,
    this.onBytesPhotoPicked,
  }) : assert(
          (kIsWeb && onBytesPhotoPicked != null) ||
              (!kIsWeb && onFilePhotoPicked != null),
          'onBytesPhotoPicked must be provided for web, onFilePhotoPicked for other platforms',
        );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickPhoto(context),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                  image: _getDecorationImage(),
                ),
                child: _hasPhoto()
                    ? null
                    : Icon(
                        placeholderIcon,
                        size: 60,
                        color: Colors.grey[400],
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
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
          labelText,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  /// Pick a photo using ImagePicker
  Future<void> _pickPhoto(BuildContext context) async {
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

      // Pick image using ImagePicker
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      if (kIsWeb) {
        // For web, we need to read the bytes
        final bytes = await pickedFile.readAsBytes();
        final extension = '.${pickedFile.name.split('.').last.toLowerCase()}';
        onBytesPhotoPicked?.call(bytes, extension);
      } else {
        // For mobile/desktop, we have the file path
        final path = pickedFile.path;
        final imageFile = File(path);
        onFilePhotoPicked?.call(imageFile);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Check if there is a photo to display
  bool _hasPhoto() {
    return photoFile != null || photoBytes != null;
  }

  /// Get the decoration image based on the platform
  DecorationImage? _getDecorationImage() {
    if (kIsWeb) {
      if (photoBytes != null) {
        return DecorationImage(
          image: MemoryImage(photoBytes!),
          fit: BoxFit.cover,
        );
      }
    } else {
      if (photoFile != null) {
        return DecorationImage(
          image: FileImage(photoFile!),
          fit: BoxFit.cover,
        );
      }
    }
    return null;
  }
}
