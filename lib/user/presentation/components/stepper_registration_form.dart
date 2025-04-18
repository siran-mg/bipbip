import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/widgets/stepper_controls.dart';
import 'package:ndao/user/presentation/components/registration_steps/account_info_step.dart';
import 'package:ndao/user/presentation/components/registration_steps/personal_info_step.dart';
import 'package:ndao/user/presentation/components/registration_steps/registration_footer.dart';

/// A stepper-based form for user registration
class StepperRegistrationForm extends StatefulWidget {
  /// Callback function when registration is successful
  final Function(
    String givenName,
    String familyName,
    String email,
    String phoneNumber,
    String password,
    File? profilePhoto,
    Uint8List? profilePhotoBytes,
    String? profilePhotoExtension,
  ) onRegister;

  /// Creates a new StepperRegistrationForm
  const StepperRegistrationForm({
    super.key,
    required this.onRegister,
  });

  @override
  State<StepperRegistrationForm> createState() =>
      _StepperRegistrationFormState();
}

class _StepperRegistrationFormState extends State<StepperRegistrationForm> {
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _accountInfoFormKey = GlobalKey<FormState>();

  final _givenNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _profilePhoto;
  Uint8List? _profilePhotoBytes;
  String? _profilePhotoExtension;
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _givenNameController.dispose();
    _familyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_accountInfoFormKey.currentState!.validate()) {
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
        _profilePhoto,
        _profilePhotoBytes,
        _profilePhotoExtension,
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
                ],
              ),
            ),

            // Footer with login link and driver registration option
            RegistrationFooter(
              alternativeText: 'Ou inscrivez-vous comme',
              alternativeIcon: Icons.directions_car,
              alternativeLabel: 'CHAUFFEUR',
              alternativeRoute: '/driver-register',
              enabled: !_isLoading,
            ),
          ],
        ),
      ],
    );
  }
}
