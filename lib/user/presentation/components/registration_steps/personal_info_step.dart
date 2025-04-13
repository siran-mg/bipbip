import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/utils/form_validators.dart';
import 'package:ndao/core/presentation/widgets/image_picker_photo_upload_widget.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

/// Personal information step for registration
class PersonalInfoStep extends StatelessWidget {
  /// Form key for validation
  final GlobalKey<FormState> formKey;

  /// Controller for given name field
  final TextEditingController givenNameController;

  /// Controller for family name field
  final TextEditingController familyNameController;

  /// Controller for phone number field
  final TextEditingController phoneController;

  /// Whether the phone number is editable
  final bool isPhoneEditable;

  /// Profile photo file (for mobile/desktop)
  final File? profilePhoto;

  /// Profile photo bytes (for web)
  final Uint8List? profilePhotoBytes;

  /// Callback when profile photo is picked (for mobile/desktop)
  final Function(File)? onProfilePhotoPicked;

  /// Callback when profile photo is picked (for web)
  final Function(Uint8List, String)? onProfilePhotoBytesPicked;

  /// Creates a new PersonalInfoStep
  const PersonalInfoStep({
    super.key,
    required this.formKey,
    required this.givenNameController,
    required this.familyNameController,
    required this.phoneController,
    this.isPhoneEditable = true,
    this.profilePhoto,
    this.profilePhotoBytes,
    this.onProfilePhotoPicked,
    this.onProfilePhotoBytesPicked,
  }) : assert(
          (kIsWeb && onProfilePhotoBytesPicked != null) ||
              (!kIsWeb && onProfilePhotoPicked != null),
          'onProfilePhotoBytesPicked must be provided for web, onProfilePhotoPicked for other platforms',
        );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile photo upload
          Center(
            child: kIsWeb
                ? ImagePickerPhotoUploadWidget(
                    photoBytes: profilePhotoBytes,
                    labelText: 'Photo de profil',
                    onBytesPhotoPicked: onProfilePhotoBytesPicked,
                  )
                : ImagePickerPhotoUploadWidget(
                    photoFile: profilePhoto,
                    labelText: 'Photo de profil',
                    onFilePhotoPicked: onProfilePhotoPicked,
                  ),
          ),

          const SizedBox(height: 24),

          // Given name field
          TextFormField(
            controller: givenNameController,
            decoration: const InputDecoration(
              labelText: 'Prénom',
              hintText: 'Entrez votre prénom',
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) =>
                FormValidators.validateRequired(value, 'prénom'),
          ),

          const SizedBox(height: 16),

          // Family name field
          TextFormField(
            controller: familyNameController,
            decoration: const InputDecoration(
              labelText: 'Nom',
              hintText: 'Entrez votre nom',
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => FormValidators.validateRequired(value, 'nom'),
          ),

          const SizedBox(height: 16),

          // Phone number field
          isPhoneEditable
              ? IntlPhoneField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    hintText: 'Entrez votre numéro de téléphone',
                    border: OutlineInputBorder(),
                  ),
                  initialCountryCode: 'MG', // Madagascar
                  invalidNumberMessage:
                      'Veuillez entrer un numéro de téléphone valide',
                  disableLengthCheck: false,
                  keyboardType: TextInputType.phone,
                  onChanged: (PhoneNumber phone) {
                    // Update the controller with the complete phone number
                    phoneController.text = phone.completeNumber;
                  },
                )
              : TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    hintText: 'Entrez votre numéro de téléphone',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  enabled: false,
                ),
        ],
      ),
    );
  }
}
