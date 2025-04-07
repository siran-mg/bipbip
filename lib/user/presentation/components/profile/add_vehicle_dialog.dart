import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ndao/user/domain/interactors/vehicle_interactor.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

/// Dialog for adding a new vehicle
class AddVehicleDialog extends StatefulWidget {
  /// The driver ID
  final String driverId;

  /// Whether this is the first vehicle (will be set as primary)
  final bool isFirstVehicle;

  /// Creates a new AddVehicleDialog
  const AddVehicleDialog({
    super.key,
    required this.driverId,
    this.isFirstVehicle = false,
  });

  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _licensePlateController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  String _selectedType = 'car'; // Default type
  bool _isPrimary = false;
  bool _isLoading = false;
  String? _errorMessage;
  File? _photoFile;

  // Vehicle types
  final List<Map<String, String>> _vehicleTypes = [
    {'key': 'car', 'label': 'Voiture'},
    {'key': 'motorcycle', 'label': 'Moto'},
    {'key': 'bicycle', 'label': 'Vélo'},
    {'key': 'other', 'label': 'Autre'},
  ];

  @override
  void initState() {
    super.initState();
    _licensePlateController = TextEditingController();
    _brandController = TextEditingController();
    _modelController = TextEditingController();
    _isPrimary = widget.isFirstVehicle; // First vehicle is primary by default
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  /// Pick a photo from the device
  Future<void> _pickPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _photoFile = File(result.files.first.path!);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Erreur lors de la sélection de la photo: ${e.toString()}';
      });
    }
  }

  /// Save the new vehicle
  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vehicleInteractor = Provider.of<VehicleInteractor>(
        context,
        listen: false,
      );

      // Create the vehicle
      final vehicle = await vehicleInteractor.createVehicle(
        driverId: widget.driverId,
        licensePlate: _licensePlateController.text.trim(),
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        type: _selectedType,
        isPrimary: _isPrimary,
        photo: _photoFile,
      );

      if (mounted) {
        Navigator.of(context).pop(vehicle);
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Erreur lors de la création du véhicule: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un véhicule'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Vehicle photo
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        image: _photoFile != null
                            ? DecorationImage(
                                image: FileImage(_photoFile!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _photoFile == null
                          ? const Icon(
                              Icons.directions_car,
                              size: 50,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: _pickPhoto,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // License plate
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'Plaque d\'immatriculation',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La plaque d\'immatriculation est requise';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Brand
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Marque',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La marque est requise';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Model
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Modèle',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le modèle est requis';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Vehicle type
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type de véhicule',
                  border: OutlineInputBorder(),
                ),
                items: _vehicleTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['key'],
                    child: Text(type['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le type de véhicule est requis';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Primary vehicle
              SwitchListTile(
                title: const Text('Véhicule principal'),
                subtitle: const Text(
                  'Ce véhicule sera utilisé par défaut pour les courses',
                ),
                value: _isPrimary,
                onChanged: widget.isFirstVehicle
                    ? null // Can't change if it's the first vehicle
                    : (value) {
                        setState(() {
                          _isPrimary = value;
                        });
                      },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveVehicle,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Ajouter'),
        ),
      ],
    );
  }
}
