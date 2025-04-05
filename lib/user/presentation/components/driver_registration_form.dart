import 'package:flutter/material.dart';

/// A form for driver registration
class DriverRegistrationForm extends StatefulWidget {
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
  ) onRegister;

  /// Creates a new DriverRegistrationForm
  const DriverRegistrationForm({
    super.key,
    required this.onRegister,
  });

  @override
  State<DriverRegistrationForm> createState() => _DriverRegistrationFormState();
}

class _DriverRegistrationFormState extends State<DriverRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
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
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
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
    _vehicleColorController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // App logo or title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              children: [
                Icon(
                  Icons.directions_bike,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Devenir chauffeur',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Inscrivez-vous comme chauffeur',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),

          // Personal Information Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Informations personnelles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Given name field
          TextFormField(
            controller: _givenNameController,
            decoration: const InputDecoration(
              labelText: 'Prénom',
              hintText: 'Entrez votre prénom',
              prefixIcon: Icon(Icons.person),
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
              labelText: 'Nom de famille',
              hintText: 'Entrez votre nom de famille',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom de famille';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Email field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Entrez votre adresse email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }

              // Simple email validation
              final emailRegExp =
                  RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
              if (!emailRegExp.hasMatch(value)) {
                return 'Veuillez entrer un email valide';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          // Phone field
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Téléphone',
              hintText: 'Entrez votre numéro de téléphone',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre numéro de téléphone';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Vehicle Information Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Informations du véhicule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // License plate field
          TextFormField(
            controller: _licensePlateController,
            decoration: const InputDecoration(
              labelText: 'Plaque d\'immatriculation',
              hintText: 'Entrez la plaque d\'immatriculation',
              prefixIcon: Icon(Icons.directions_car),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer la plaque d\'immatriculation';
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
              prefixIcon: Icon(Icons.two_wheeler),
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

          // Vehicle color field
          TextFormField(
            controller: _vehicleColorController,
            decoration: const InputDecoration(
              labelText: 'Couleur du véhicule',
              hintText: 'Entrez la couleur du véhicule',
              prefixIcon: Icon(Icons.color_lens),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer la couleur du véhicule';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Vehicle type dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Type de véhicule',
              prefixIcon: Icon(Icons.category),
              border: OutlineInputBorder(),
            ),
            value: _selectedVehicleType,
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

          const SizedBox(height: 24),

          // Account Information Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Informations du compte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Password field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              hintText: 'Créez un mot de passe',
              prefixIcon: const Icon(Icons.lock),
              border: const OutlineInputBorder(),
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
                return 'Veuillez entrer un mot de passe';
              }

              if (value.length < 8) {
                return 'Le mot de passe doit contenir au moins 8 caractères';
              }

              // Check for password complexity
              bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
              bool hasLowercase = value.contains(RegExp(r'[a-z]'));
              bool hasDigit = value.contains(RegExp(r'[0-9]'));
              bool hasSpecialChar =
                  value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

              if (!(hasUppercase && hasLowercase && hasDigit) &&
                  !hasSpecialChar) {
                return 'Le mot de passe doit contenir au moins 3 des éléments suivants: majuscules, minuscules, chiffres, caractères spéciaux';
              }

              // Check for common passwords
              List<String> commonPasswords = [
                'password',
                '12345678',
                'qwerty123',
                'admin123',
                '123456789'
              ];
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
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
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

          const SizedBox(height: 24),

          // Register button
          SizedBox(
            height: 50,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : FilledButton(
                    onPressed: _submitForm,
                    child: const Text(
                      'S\'INSCRIRE COMME CHAUFFEUR',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
          ),

          const SizedBox(height: 24),

          // Login link
          Row(
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
      ),
    );
  }
}
