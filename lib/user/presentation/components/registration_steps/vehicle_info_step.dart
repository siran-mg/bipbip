import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/utils/form_validators.dart';
import 'package:ndao/core/presentation/widgets/photo_upload_widget.dart';

/// Vehicle information step for driver registration
class VehicleInfoStep extends StatelessWidget {
  /// Form key for validation
  final GlobalKey<FormState> formKey;
  
  /// Controller for license plate field
  final TextEditingController licensePlateController;
  
  /// Controller for vehicle model field
  final TextEditingController vehicleModelController;
  
  /// Controller for vehicle color field
  final TextEditingController vehicleColorController;
  
  /// Selected vehicle type
  final String selectedVehicleType;
  
  /// Vehicle photo file
  final File? vehiclePhoto;
  
  /// Callback when vehicle type is changed
  final Function(String) onVehicleTypeChanged;
  
  /// Callback when vehicle photo is picked
  final Function(File) onVehiclePhotoPicked;
  
  /// List of vehicle types
  final List<Map<String, dynamic>> vehicleTypes;

  /// Creates a new VehicleInfoStep
  const VehicleInfoStep({
    super.key,
    required this.formKey,
    required this.licensePlateController,
    required this.vehicleModelController,
    required this.vehicleColorController,
    required this.selectedVehicleType,
    required this.vehiclePhoto,
    required this.onVehicleTypeChanged,
    required this.onVehiclePhotoPicked,
    required this.vehicleTypes,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle photo upload
          Center(
            child: PhotoUploadWidget(
              photoFile: vehiclePhoto,
              placeholderIcon: Icons.directions_car,
              labelText: 'Photo du véhicule',
              onPhotoPicked: onVehiclePhotoPicked,
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
          
          // Vehicle color field
          TextFormField(
            controller: vehicleColorController,
            decoration: const InputDecoration(
              labelText: 'Couleur du véhicule',
              hintText: 'Entrez la couleur de votre véhicule',
              prefixIcon: Icon(Icons.color_lens),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => FormValidators.validateRequired(
              value, 
              'couleur du véhicule',
            ),
          ),
        ],
      ),
    );
  }
}
