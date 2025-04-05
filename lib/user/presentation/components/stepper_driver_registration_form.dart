import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/widgets/photo_upload_widget.dart';

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
    Key? key,
    required this.onRegister,
  }) : super(key: key);

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
  final _vehicleColorController = TextEditingController();

  String _selectedVehicleType = 'motorcycle';
  File? _profilePhoto;
  File? _vehiclePhoto;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  int _currentStep = 0;

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
    _vehicleColorController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_vehicleInfoFormKey.currentState!.validate()) {
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
        _vehicleColorController.text.trim(),
        _selectedVehicleType,
        _profilePhoto,
        _vehiclePhoto,
      )
          .then((_) {
        // Handle successful registration if needed
      }).catchError((error) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inscription échouée: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }).whenComplete(() {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            onStepContinue: () {
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
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep -= 1;
                });
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: details.onStepContinue,
                        child: Text(
                          _currentStep == 2 ? 'S\'INSCRIRE' : 'CONTINUER',
                        ),
                      ),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          child: const Text('RETOUR'),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Profil'),
                content: _buildPersonalInfoStep(),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Compte'),
                content: _buildAccountInfoStep(),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Véhicule'),
                content: _buildVehicleInfoStep(),
                isActive: _currentStep >= 2,
                state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              ),
            ],
          ),
        ),
        
        // Login link
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Vous avez déjà un compte?'),
              TextButton(
                onPressed: () {
                  // Navigate back to login page
                  Navigator.pop(context);
                },
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
        
        // Client registration link
        const SizedBox(height: 16),
        
        // Divider with text
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Ou inscrivez-vous comme',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Client registration button
        OutlinedButton.icon(
          onPressed: () {
            // Navigate to client registration page
            Navigator.pushReplacementNamed(context, '/register');
          },
          icon: const Icon(Icons.person_add),
          label: const Text('CLIENT'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoStep() {
    return Form(
      key: _personalInfoFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile photo upload
          Center(
            child: PhotoUploadWidget(
              photoFile: _profilePhoto,
              labelText: 'Photo de profil',
              onPhotoPicked: (file) {
                setState(() {
                  _profilePhoto = file;
                });
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Given name field
          TextFormField(
            controller: _givenNameController,
            decoration: const InputDecoration(
              labelText: 'Prénom',
              hintText: 'Entrez votre prénom',
              prefixIcon: Icon(Icons.person),
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
              prefixIcon: Icon(Icons.person),
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
          
          // Phone number field
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Téléphone',
              hintText: 'Entrez votre numéro de téléphone',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre numéro de téléphone';
              }
              
              // Simple phone number validation
              final phoneRegExp = RegExp(r'^\d{10}$');
              if (!phoneRegExp.hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
                return 'Veuillez entrer un numéro de téléphone valide';
              }
              
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoStep() {
    return Form(
      key: _accountInfoFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Entrez votre adresse email',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              
              // Simple email validation
              final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
              if (!emailRegExp.hasMatch(value)) {
                return 'Veuillez entrer un email valide';
              }
              
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Password field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              hintText: 'Entrez votre mot de passe',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            obscureText: !_isPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre mot de passe';
              }
              
              if (value.length < 8) {
                return 'Le mot de passe doit contenir au moins 8 caractères';
              }
              
              // Check for password complexity
              bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
              bool hasLowercase = value.contains(RegExp(r'[a-z]'));
              bool hasDigit = value.contains(RegExp(r'[0-9]'));
              bool hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
              
              if (!(hasUppercase && hasLowercase && hasDigit) && !hasSpecialChar) {
                return 'Le mot de passe doit contenir au moins 3 des éléments suivants: majuscules, minuscules, chiffres, caractères spéciaux';
              }
              
              // Check for common passwords
              List<String> commonPasswords = ['password', '12345678', 'qwerty123', 'admin123', '123456789'];
              if (commonPasswords.contains(value.toLowerCase())) {
                return 'Ce mot de passe est trop courant. Veuillez en choisir un plus sécurisé';
              }
              
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Confirm password field
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirmer le mot de passe',
              hintText: 'Confirmez votre mot de passe',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
            obscureText: !_isConfirmPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez confirmer votre mot de passe';
              }
              
              if (value != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoStep() {
    return Form(
      key: _vehicleInfoFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle photo upload
          Center(
            child: PhotoUploadWidget(
              photoFile: _vehiclePhoto,
              placeholderIcon: Icons.directions_car,
              labelText: 'Photo du véhicule',
              onPhotoPicked: (file) {
                setState(() {
                  _vehiclePhoto = file;
                });
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Vehicle type dropdown
          DropdownButtonFormField<String>(
            value: _selectedVehicleType,
            decoration: const InputDecoration(
              labelText: 'Type de véhicule',
              prefixIcon: Icon(Icons.category),
            ),
            items: _vehicleTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type['value'],
                child: Text(type['label']),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedVehicleType = value;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez sélectionner un type de véhicule';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // License plate field
          TextFormField(
            controller: _licensePlateController,
            decoration: const InputDecoration(
              labelText: 'Plaque d\'immatriculation',
              hintText: 'Entrez votre plaque d\'immatriculation',
              prefixIcon: Icon(Icons.credit_card),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre plaque d\'immatriculation';
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
              hintText: 'Entrez le modèle de votre véhicule',
              prefixIcon: Icon(Icons.directions_car),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le modèle de votre véhicule';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Vehicle color field
          TextFormField(
            controller: _vehicleColorController,
            decoration: const InputDecoration(
              labelText: 'Couleur du véhicule',
              hintText: 'Entrez la couleur de votre véhicule',
              prefixIcon: Icon(Icons.color_lens),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer la couleur de votre véhicule';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
