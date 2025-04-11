import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/utils/form_validators.dart';
import 'package:ndao/core/presentation/widgets/image_picker_photo_upload_widget.dart';

/// Vehicle information step for driver registration
class VehicleInfoStep extends StatelessWidget {
  /// Form key for validation
  final GlobalKey<FormState> formKey;

  /// Controller for license plate field
  final TextEditingController licensePlateController;

  /// Controller for vehicle model field
  final TextEditingController vehicleModelController;

  /// Controller for vehicle brand field
  final TextEditingController vehicleBrandController;

  /// Selected vehicle type
  final String selectedVehicleType;

  /// Vehicle photo file (for mobile/desktop)
  final File? vehiclePhoto;

  /// Vehicle photo bytes (for web)
  final Uint8List? vehiclePhotoBytes;

  /// Callback when vehicle type is changed
  final Function(String) onVehicleTypeChanged;

  /// Callback when vehicle photo is picked (for mobile/desktop)
  final Function(File)? onVehiclePhotoPicked;

  /// Callback when vehicle photo is picked (for web)
  final Function(Uint8List, String)? onVehiclePhotoBytesPicked;

  /// List of vehicle types
  final List<Map<String, dynamic>> vehicleTypes;

  /// Creates a new VehicleInfoStep
  const VehicleInfoStep({
    super.key,
    required this.formKey,
    required this.licensePlateController,
    required this.vehicleModelController,
    required this.vehicleBrandController,
    required this.selectedVehicleType,
    this.vehiclePhoto,
    this.vehiclePhotoBytes,
    required this.onVehicleTypeChanged,
    this.onVehiclePhotoPicked,
    this.onVehiclePhotoBytesPicked,
    required this.vehicleTypes,
  }) : assert(
          (kIsWeb && onVehiclePhotoBytesPicked != null) ||
              (!kIsWeb && onVehiclePhotoPicked != null),
          'onVehiclePhotoBytesPicked must be provided for web, onVehiclePhotoPicked for other platforms',
        );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle photo upload
          Center(
            child: kIsWeb
                ? ImagePickerPhotoUploadWidget(
                    photoBytes: vehiclePhotoBytes,
                    placeholderIcon: Icons.directions_car,
                    labelText: 'Photo du véhicule',
                    onBytesPhotoPicked: onVehiclePhotoBytesPicked,
                  )
                : ImagePickerPhotoUploadWidget(
                    photoFile: vehiclePhoto,
                    placeholderIcon: Icons.directions_car,
                    labelText: 'Photo du véhicule',
                    onFilePhotoPicked: onVehiclePhotoPicked,
                  ),
          ),

          const SizedBox(height: 24),

          // Vehicle type dropdown
          DropdownButtonFormField<String>(
            value: selectedVehicleType,
            decoration: const InputDecoration(
              labelText: 'Type de véhicule',
              prefixIcon: Icon(Icons.category),
            ),
            items: vehicleTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type['value'],
                child: Text(type['label']),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onVehicleTypeChanged(value);
              }
            },
            validator: (value) => FormValidators.validateRequired(
              value,
              'type de véhicule',
            ),
          ),

          const SizedBox(height: 16),

          // License plate field
          TextFormField(
            controller: licensePlateController,
            decoration: const InputDecoration(
              labelText: 'Plaque d\'immatriculation',
              hintText: 'Entrez votre plaque d\'immatriculation',
              prefixIcon: Icon(Icons.credit_card),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (value) => FormValidators.validateRequired(
              value,
              'plaque d\'immatriculation',
            ),
          ),

          const SizedBox(height: 16),

          // Vehicle model field
          TextFormField(
            controller: vehicleModelController,
            decoration: const InputDecoration(
              labelText: 'Modèle du véhicule',
              hintText: 'Entrez le modèle de votre véhicule',
              prefixIcon: Icon(Icons.directions_car),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => FormValidators.validateRequired(
              value,
              'modèle du véhicule',
            ),
          ),

          const SizedBox(height: 16),

          // Vehicle brand field
          TextFormField(
            controller: vehicleBrandController,
            decoration: const InputDecoration(
              labelText: 'Marque du véhicule',
              hintText: 'Entrez la marque de votre véhicule',
              prefixIcon: Icon(Icons.business),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => FormValidators.validateRequired(
              value,
              'marque du véhicule',
            ),
          ),
        ],
      ),
    );
  }
}
