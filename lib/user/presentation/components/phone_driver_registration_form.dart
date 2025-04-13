import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ndao/vehicle/domain/entities/vehicle_type.dart';

/// A form for driver registration with phone number
class PhoneDriverRegistrationForm extends StatefulWidget {
  /// User ID from authentication
  final String userId;

  /// Phone number from authentication
  final String phoneNumber;

  /// Callback function when registration is successful
  final Future<void> Function(
    String givenName,
    String familyName,
    String email,
    String licensePlate,
    String vehicleModel,
    String vehicleBrand,
    String vehicleType,
    File? profilePhoto,
    File? vehiclePhoto,
  ) onRegister;

  /// Creates a new PhoneDriverRegistrationForm
  const PhoneDriverRegistrationForm({
    super.key,
    required this.userId,
    required this.phoneNumber,
    required this.onRegister,
  });

  @override
  State<PhoneDriverRegistrationForm> createState() =>
      _PhoneDriverRegistrationFormState();
}

class _PhoneDriverRegistrationFormState
    extends State<PhoneDriverRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _givenNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleBrandController = TextEditingController();
  String _selectedVehicleType = VehicleType.moto;
  File? _profilePhoto;
  File? _vehiclePhoto;
  bool _isLoading = false;

  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _givenNameController.dispose();
    _familyNameController.dispose();
    _emailController.dispose();
    _licensePlateController.dispose();
    _vehicleModelController.dispose();
    _vehicleBrandController.dispose();
    super.dispose();
  }

  /// Handle registration button press
  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await widget.onRegister(
          _givenNameController.text,
          _familyNameController.text,
          _emailController.text,
          _licensePlateController.text,
          _vehicleModelController.text,
          _vehicleBrandController.text,
          _selectedVehicleType,
          _profilePhoto,
          _vehiclePhoto,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  /// Pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source, bool isProfilePhoto) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          if (isProfilePhoto) {
            _profilePhoto = File(pickedFile.path);
          } else {
            _vehiclePhoto = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
          ),
        );
      }
    }
  }

  /// Show image source selection dialog
  Future<void> _showImageSourceDialog(bool isProfilePhoto) async {
    final title = isProfilePhoto
        ? 'Sélectionner une photo de profil'
        : 'Sélectionner une photo du véhicule';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, isProfilePhoto);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Caméra'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, isProfilePhoto);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Text(
                  'Complétez votre profil',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Veuillez fournir les informations suivantes pour créer votre compte chauffeur',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Phone number display (non-editable)
          TextFormField(
            initialValue: widget.phoneNumber,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            enabled: false,
          ),

          const SizedBox(height: 16),

          // Personal Information Section
          _buildSectionTitle(context, 'Informations personnelles'),

          const SizedBox(height: 16),

          // Given name field
          TextFormField(
            controller: _givenNameController,
            decoration: const InputDecoration(
              labelText: 'Prénom',
              hintText: 'Entrez votre prénom',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre prénom';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Family name field
          TextFormField(
            controller: _familyNameController,
            decoration: const InputDecoration(
              labelText: 'Nom',
              hintText: 'Entrez votre nom',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Email field (optional)
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email (optionnel)',
              hintText: 'Entrez votre email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                // Only validate if email is provided
                final emailRegExp =
                    RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
                if (!emailRegExp.hasMatch(value)) {
                  return 'Veuillez entrer un email valide';
                }
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Profile photo
          InkWell(
            onTap: () => _showImageSourceDialog(true),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _profilePhoto != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _profilePhoto!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        const Text('Ajouter une photo de profil (optionnel)'),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 32),

          // Vehicle Information Section
          _buildSectionTitle(context, 'Informations du véhicule'),

          const SizedBox(height: 16),

          // License plate field
          TextFormField(
            controller: _licensePlateController,
            decoration: const InputDecoration(
              labelText: 'Numéro d\'immatriculation',
              hintText: 'Entrez le numéro d\'immatriculation',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le numéro d\'immatriculation';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Vehicle brand field
          TextFormField(
            controller: _vehicleBrandController,
            decoration: const InputDecoration(
              labelText: 'Marque du véhicule',
              hintText: 'Entrez la marque du véhicule',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer la marque du véhicule';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Vehicle model field
          TextFormField(
            controller: _vehicleModelController,
            decoration: const InputDecoration(
              labelText: 'Modèle du véhicule',
              hintText: 'Entrez le modèle du véhicule',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le modèle du véhicule';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Vehicle type dropdown
          DropdownButtonFormField<String>(
            value: _selectedVehicleType,
            decoration: const InputDecoration(
              labelText: 'Type de véhicule',
              border: OutlineInputBorder(),
            ),
            items: VehicleType.getAllTypes().map((type) {
              return DropdownMenuItem<String>(
                value: type['value'] ?? '',
                child: Text(type['label'] ?? ''),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedVehicleType = value;
                });
              }
            },
          ),

          const SizedBox(height: 16),

          // Vehicle photo
          InkWell(
            onTap: () => _showImageSourceDialog(false),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _vehiclePhoto != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _vehiclePhoto!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        const Text('Ajouter une photo du véhicule (optionnel)'),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 32),

          // Register button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('CRÉER MON COMPTE'),
          ),
        ],
      ),
    );
  }

  /// Build a section title
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider()),
      ],
    );
  }
}
