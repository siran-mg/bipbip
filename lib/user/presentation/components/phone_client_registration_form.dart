import 'package:flutter/material.dart';

/// A form for client registration with phone number
class PhoneClientRegistrationForm extends StatefulWidget {
  /// User ID from authentication
  final String userId;

  /// Phone number from authentication
  final String phoneNumber;

  /// Callback function when registration is successful
  final Future<void> Function(
    String givenName,
    String familyName,
    String email,
  ) onRegister;

  /// Creates a new PhoneClientRegistrationForm
  const PhoneClientRegistrationForm({
    super.key,
    required this.userId,
    required this.phoneNumber,
    required this.onRegister,
  });

  @override
  State<PhoneClientRegistrationForm> createState() =>
      _PhoneClientRegistrationFormState();
}

class _PhoneClientRegistrationFormState
    extends State<PhoneClientRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _givenNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _givenNameController.dispose();
    _familyNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Handle registration button press
  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await widget.onRegister(
          _givenNameController.text,
          _familyNameController.text,
          _emailController.text,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Text(
                  'Complétez votre profil',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Veuillez fournir les informations suivantes pour créer votre compte client',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Phone number display (non-editable)
          TextFormField(
            initialValue: widget.phoneNumber,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            enabled: false,
          ),

          const SizedBox(height: 16),

          // Given name field
          TextFormField(
            controller: _givenNameController,
            decoration: const InputDecoration(
              labelText: 'Prénom',
              hintText: 'Entrez votre prénom',
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
              labelText: 'Nom',
              hintText: 'Entrez votre nom',
              border: OutlineInputBorder(),
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

          // Email field (optional)
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email (optionnel)',
              hintText: 'Entrez votre email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                // Only validate if email is provided
                final emailRegExp =
                    RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
                if (!emailRegExp.hasMatch(value)) {
                  return 'Veuillez entrer un email valide';
                }
              }
              return null;
            },
          ),

          const SizedBox(height: 32),

          // Register button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('CRÉER MON COMPTE'),
          ),
        ],
      ),
    );
  }
}
