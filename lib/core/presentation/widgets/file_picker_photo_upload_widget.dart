import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Widget for uploading and displaying a photo using FilePicker
/// This works consistently across all platforms including web
class FilePickerPhotoUploadWidget extends StatelessWidget {
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

  /// Creates a new FilePickerPhotoUploadWidget
  const FilePickerPhotoUploadWidget({
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
          onTap: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.image,
              allowMultiple: false,
            );

            if (result == null || result.files.isEmpty) {
              return;
            }

            final file = result.files.first;

            if (kIsWeb) {
              // For web, we have the bytes directly from FilePicker
              if (file.bytes == null) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur: Impossible de lire le fichier'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final bytes = file.bytes!;
              final extension = '.${file.extension?.toLowerCase() ?? 'jpg'}';
              onBytesPhotoPicked?.call(bytes, extension);
            } else {
              // For mobile/desktop, we have the file path
              if (file.path == null) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur: Chemin du fichier invalide'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final path = file.path!;
              final imageFile = File(path);
              onFilePhotoPicked?.call(imageFile);
            }
          },
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
