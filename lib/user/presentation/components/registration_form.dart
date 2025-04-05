import 'package:flutter/material.dart';

/// A form for user registration
class RegistrationForm extends StatefulWidget {
  /// Callback function when registration is successful
  final Function(String givenName, String familyName, String email,
      String phoneNumber, String password) onRegister;

  /// Creates a new RegistrationForm
  const RegistrationForm({
    super.key,
    required this.onRegister,
  });

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _givenNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
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
      )
          .then((_) {
        // Handle successful registration if needed
      }).catchError((error) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${error.toString()}'),
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
                  'Créer un compte',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Inscrivez-vous pour commencer',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
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

          const SizedBox(height: 16),

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
                      'S\'INSCRIRE',
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

          // Driver registration link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Vous êtes chauffeur?'),
              TextButton(
                onPressed: () {
                  // Navigate to driver registration page
                  Navigator.pushReplacementNamed(context, '/driver-register');
                },
                child: const Text('Devenir chauffeur'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
