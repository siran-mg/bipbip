import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/utils/image_picker_util.dart';

/// Widget for uploading and displaying a photo
class PhotoUploadWidget extends StatelessWidget {
  /// The current photo file
  final File? photoFile;
  
  /// The placeholder image asset path
  final String placeholderAsset;
  
  /// The placeholder icon
  final IconData placeholderIcon;
  
  /// The label text
  final String labelText;
  
  /// Callback when photo is picked
  final Function(File) onPhotoPicked;
  
  /// Creates a new PhotoUploadWidget
  const PhotoUploadWidget({
    Key? key,
    this.photoFile,
    this.placeholderAsset = 'assets/images/profile_placeholder.png',
    this.placeholderIcon = Icons.person,
    required this.labelText,
    required this.onPhotoPicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final pickedFile = await ImagePickerUtil.pickImage(context);
            if (pickedFile != null) {
              onPhotoPicked(pickedFile);
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
                  image: photoFile != null
                      ? DecorationImage(
                          image: FileImage(photoFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photoFile == null
                    ? Icon(
                        placeholderIcon,
                        size: 60,
                        color: Colors.grey[400],
                      )
                    : null,
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
}
