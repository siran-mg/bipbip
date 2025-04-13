import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/widgets/stepper_controls.dart';
import 'package:ndao/user/presentation/components/registration_steps/personal_info_step.dart';
import 'package:ndao/user/presentation/components/registration_steps/registration_footer.dart';

/// A stepper-based form for user registration with phone authentication
class PhoneStepperRegistrationForm extends StatefulWidget {
  /// Phone number from authentication
  final String phoneNumber;

  /// User ID from authentication
  final String userId;

  /// Callback function when registration is successful
  final Function(
    String givenName,
    String familyName,
    String email,
    File? profilePhoto,
    Uint8List? profilePhotoBytes,
    String? profilePhotoExtension,
  ) onRegister;

  /// Creates a new PhoneStepperRegistrationForm
  const PhoneStepperRegistrationForm({
    super.key,
    required this.phoneNumber,
    required this.userId,
    required this.onRegister,
  });

  @override
  State<PhoneStepperRegistrationForm> createState() =>
      _PhoneStepperRegistrationFormState();
}

class _PhoneStepperRegistrationFormState
    extends State<PhoneStepperRegistrationForm> {
  final _personalInfoFormKey = GlobalKey<FormState>();

  final _givenNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _profilePhoto;
  Uint8List? _profilePhotoBytes;
  String? _profilePhotoExtension;

  int _currentStep = 0;
  bool _isLoading = false;

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
    super.dispose();
  }

  void _submitForm() {
    if (_personalInfoFormKey.currentState!.validate()) {
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
        _profilePhoto,
        _profilePhotoBytes,
        _profilePhotoExtension,
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
                    totalSteps: 1,
                    onStepContinue: details.onStepContinue,
                    onStepCancel: details.onStepCancel,
                    isLoading: _isLoading,
                    continueText: 'CRÉER MON COMPTE',
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
                      isPhoneEditable: false,
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
                ],
              ),
            ),

            // Footer with driver registration option
            RegistrationFooter(
              alternativeText: 'Ou inscrivez-vous comme',
              alternativeIcon: Icons.directions_car,
              alternativeLabel: 'CHAUFFEUR',
              alternativeRoute: '/driver-register',
              enabled: !_isLoading,
            ),
          ],
        ),

        // Loading overlay
        if (_isLoading)
          Container(
            color: Colors.black.withAlpha(76),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
