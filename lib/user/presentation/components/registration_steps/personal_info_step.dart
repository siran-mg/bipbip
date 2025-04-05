import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/utils/form_validators.dart';
import 'package:ndao/core/presentation/widgets/photo_upload_widget.dart';

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
  
  /// Profile photo file
  final File? profilePhoto;
  
  /// Callback when profile photo is picked
  final Function(File) onProfilePhotoPicked;

  /// Creates a new PersonalInfoStep
  const PersonalInfoStep({
    super.key,
    required this.formKey,
    required this.givenNameController,
    required this.familyNameController,
    required this.phoneController,
    required this.profilePhoto,
    required this.onProfilePhotoPicked,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile photo upload
          Center(
            child: PhotoUploadWidget(
              photoFile: profilePhoto,
              labelText: 'Photo de profil',
              onPhotoPicked: onProfilePhotoPicked,
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
            validator: (value) => FormValidators.validateRequired(value, 'prénom'),
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
          TextFormField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Téléphone',
              hintText: 'Entrez votre numéro de téléphone',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: FormValidators.validatePhoneNumber,
          ),
        ],
      ),
    );
  }
}
