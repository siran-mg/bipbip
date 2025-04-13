import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/widgets/stepper_controls.dart';
import 'package:ndao/user/presentation/components/registration_steps/personal_info_step.dart';
import 'package:ndao/user/presentation/components/registration_steps/registration_footer.dart';
import 'package:ndao/user/presentation/components/registration_steps/vehicle_info_step.dart';

/// A stepper-based form for driver registration with phone authentication
class PhoneStepperDriverRegistrationForm extends StatefulWidget {
  /// Phone number from authentication
  final String phoneNumber;

  /// User ID from authentication
  final String userId;

  /// Callback function when registration is successful
  final Function(
    String givenName,
    String familyName,
    String email,
    String licensePlate,
    String vehicleModel,
    String vehicleBrand,
    String vehicleType,
    File? profilePhoto,
    File? vehiclePhoto,
    Uint8List? profilePhotoBytes,
    String? profilePhotoExtension,
    Uint8List? vehiclePhotoBytes,
    String? vehiclePhotoExtension,
  ) onRegister;

  /// Creates a new PhoneStepperDriverRegistrationForm
  const PhoneStepperDriverRegistrationForm({
    super.key,
    required this.phoneNumber,
    required this.userId,
    required this.onRegister,
  });

  @override
  State<PhoneStepperDriverRegistrationForm> createState() =>
      _PhoneStepperDriverRegistrationFormState();
}

class _PhoneStepperDriverRegistrationFormState
    extends State<PhoneStepperDriverRegistrationForm> {
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _vehicleInfoFormKey = GlobalKey<FormState>();

  final _givenNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleBrandController = TextEditingController();

  String _selectedVehicleType = 'motorcycle';
  File? _profilePhoto;
  File? _vehiclePhoto;
  Uint8List? _profilePhotoBytes;
  String? _profilePhotoExtension;
  Uint8List? _vehiclePhotoBytes;
  String? _vehiclePhotoExtension;

  int _currentStep = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _vehicleTypes = [
    {'value': 'motorcycle', 'label': 'Moto'},
    {'value': 'car', 'label': 'Voiture'},
    {'value': 'bicycle', 'label': 'Vélo'},
    {'value': 'other', 'label': 'Autre'},
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill the phone number
    _phoneController.text = widget.phoneNumber;
  }

  @override
  void dispose() {
    _givenNameController.dispose();
    _familyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licensePlateController.dispose();
    _vehicleModelController.dispose();
    _vehicleBrandController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_vehicleInfoFormKey.currentState!.validate()) {
      // Set loading state
      setState(() {
        _isLoading = true;
      });

      // Call the onRegister callback with the form values
      widget
          .onRegister(
        _givenNameController.text.trim(),
        _familyNameController.text.trim(),
        _emailController.text.trim(),
        _licensePlateController.text.trim(),
        _vehicleModelController.text.trim(),
        _vehicleBrandController.text.trim(),
        _selectedVehicleType,
        _profilePhoto,
        _vehiclePhoto,
        _profilePhotoBytes,
        _profilePhotoExtension,
        _vehiclePhotoBytes,
        _vehiclePhotoExtension,
      )
          .then((_) {
        // Registration successful
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }).catchError((error) {
        // Registration failed
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: _currentStep,
                onStepContinue: _isLoading
                    ? null
                    : () {
                        if (_currentStep == 0) {
                          if (_personalInfoFormKey.currentState!.validate()) {
                            setState(() {
                              _currentStep += 1;
                            });
                          }
                        } else if (_currentStep == 1) {
                          _submitForm();
                        }
                      },
                onStepCancel: _isLoading
                    ? null
                    : () {
                        if (_currentStep > 0) {
                          setState(() {
                            _currentStep -= 1;
                          });
                        }
                      },
                controlsBuilder: (context, details) {
                  return StepperControls(
                    currentStep: _currentStep,
                    totalSteps: 2,
                    onStepContinue: details.onStepContinue,
                    onStepCancel: details.onStepCancel,
                    isLoading: _isLoading,
                    continueText:
                        _currentStep == 1 ? 'CRÉER MON COMPTE' : 'CONTINUER',
                  );
                },
                steps: [
                  Step(
                    title: const Text('Profil'),
                    content: PersonalInfoStep(
                      formKey: _personalInfoFormKey,
                      givenNameController: _givenNameController,
                      familyNameController: _familyNameController,
                      phoneController: _phoneController,
                      profilePhoto: _profilePhoto,
                      profilePhotoBytes: _profilePhotoBytes,
                      onProfilePhotoPicked: kIsWeb
                          ? null
                          : (file) {
                              setState(() {
                                _profilePhoto = file;
                                _profilePhotoBytes = null;
                                _profilePhotoExtension = null;
                              });
                            },
                      onProfilePhotoBytesPicked: kIsWeb
                          ? (bytes, extension) {
                              setState(() {
                                _profilePhotoBytes = bytes;
                                _profilePhotoExtension = extension;
                                _profilePhoto = null;
                              });
                            }
                          : null,
                    ),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Véhicule'),
                    content: VehicleInfoStep(
                      formKey: _vehicleInfoFormKey,
                      licensePlateController: _licensePlateController,
                      vehicleModelController: _vehicleModelController,
                      vehicleBrandController: _vehicleBrandController,
                      selectedVehicleType: _selectedVehicleType,
                      vehiclePhoto: _vehiclePhoto,
                      vehiclePhotoBytes: _vehiclePhotoBytes,
                      onVehicleTypeChanged: (value) {
                        setState(() {
                          _selectedVehicleType = value;
                        });
                      },
                      onVehiclePhotoPicked: kIsWeb
                          ? null
                          : (file) {
                              setState(() {
                                _vehiclePhoto = file;
                                _vehiclePhotoBytes = null;
                                _vehiclePhotoExtension = null;
                              });
                            },
                      onVehiclePhotoBytesPicked: kIsWeb
                          ? (bytes, extension) {
                              setState(() {
                                _vehiclePhotoBytes = bytes;
                                _vehiclePhotoExtension = extension;
                                _vehiclePhoto = null;
                              });
                            }
                          : null,
                      vehicleTypes: _vehicleTypes,
                    ),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                ],
              ),
            ),

            // Footer with client registration option
            RegistrationFooter(
              alternativeText: 'Ou inscrivez-vous comme',
              alternativeIcon: Icons.person_add,
              alternativeLabel: 'CLIENT',
              alternativeRoute: '/register',
              enabled: !_isLoading,
            ),
          ],
        ),

        // Loading overlay
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
