import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/widgets/stepper_controls.dart';
import 'package:ndao/user/presentation/components/registration_steps/account_info_step.dart';
import 'package:ndao/user/presentation/components/registration_steps/personal_info_step.dart';
import 'package:ndao/user/presentation/components/registration_steps/registration_footer.dart';
import 'package:ndao/user/presentation/components/registration_steps/vehicle_info_step.dart';

/// A stepper-based form for driver registration
class StepperDriverRegistrationForm extends StatefulWidget {
  /// Callback function when registration is successful
  final Function(
    String givenName,
    String familyName,
    String email,
    String phoneNumber,
    String password,
    String licensePlate,
    String vehicleModel,
    String vehicleColor,
    String vehicleType,
    File? profilePhoto,
    File? vehiclePhoto,
  ) onRegister;

  /// Creates a new StepperDriverRegistrationForm
  const StepperDriverRegistrationForm({
    super.key,
    required this.onRegister,
  });

  @override
  State<StepperDriverRegistrationForm> createState() =>
      _StepperDriverRegistrationFormState();
}

class _StepperDriverRegistrationFormState
    extends State<StepperDriverRegistrationForm> {
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _accountInfoFormKey = GlobalKey<FormState>();
  final _vehicleInfoFormKey = GlobalKey<FormState>();

  final _givenNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleBrandController = TextEditingController();

  String _selectedVehicleType = 'motorcycle';
  File? _profilePhoto;
  File? _vehiclePhoto;
  int _currentStep = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _vehicleTypes = [
    {'value': 'motorcycle', 'label': 'Moto'},
    {'value': 'car', 'label': 'Voiture'},
    {'value': 'bicycle', 'label': 'Vélo'},
    {'value': 'other', 'label': 'Autre'},
  ];

  @override
  void dispose() {
    _givenNameController.dispose();
    _familyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
        _phoneController.text.trim(),
        _passwordController.text,
        _licensePlateController.text.trim(),
        _vehicleModelController.text.trim(),
        _vehicleBrandController.text.trim(),
        _selectedVehicleType,
        _profilePhoto,
        _vehiclePhoto,
      )
          .then((_) {
        // Handle successful registration if needed
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }).catchError((error) {
        // Show error message
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Inscription échouée: ${error.toString()}'),
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
                          if (_accountInfoFormKey.currentState!.validate()) {
                            setState(() {
                              _currentStep += 1;
                            });
                          }
                        } else if (_currentStep == 2) {
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
                    totalSteps: 3,
                    onStepContinue: details.onStepContinue,
                    onStepCancel: details.onStepCancel,
                    isLoading: _isLoading,
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
                      onProfilePhotoPicked: (file) {
                        setState(() {
                          _profilePhoto = file;
                        });
                      },
                    ),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Compte'),
                    content: AccountInfoStep(
                      formKey: _accountInfoFormKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                    ),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1
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
                      onVehicleTypeChanged: (value) {
                        setState(() {
                          _selectedVehicleType = value;
                        });
                      },
                      onVehiclePhotoPicked: (file) {
                        setState(() {
                          _vehiclePhoto = file;
                        });
                      },
                      vehicleTypes: _vehicleTypes,
                    ),
                    isActive: _currentStep >= 2,
                    state: _currentStep > 2
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                ],
              ),
            ),

            // Footer with login link and client registration option
            RegistrationFooter(
              alternativeText: 'Ou inscrivez-vous comme',
              alternativeIcon: Icons.person_add,
              alternativeLabel: 'CLIENT',
              alternativeRoute: '/register',
              enabled: !_isLoading,
            ),
          ],
        ),
      ],
    );
  }
}
