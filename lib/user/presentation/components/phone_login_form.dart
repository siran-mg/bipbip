import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

/// A form for user login with phone number
class PhoneLoginForm extends StatefulWidget {
  /// Callback function when login is initiated
  final Function(String phoneNumber) onLogin;

  /// Creates a new PhoneLoginForm
  const PhoneLoginForm({
    super.key,
    required this.onLogin,
  });

  @override
  State<PhoneLoginForm> createState() => _PhoneLoginFormState();
}

class _PhoneLoginFormState extends State<PhoneLoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _completePhoneNumber = '';
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  /// Handle login button press
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate() && _completePhoneNumber.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        await widget.onLogin(_completePhoneNumber);
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
          // App logo or title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Column(
              children: [
                Icon(
                  Icons.directions_bike,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ndao',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous pour continuer',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),

          // Phone number field with country code
          IntlPhoneField(
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone',
              hintText: 'Entrez votre numéro de téléphone',
              border: OutlineInputBorder(),
            ),
            initialCountryCode: 'MG', // Madagascar
            invalidNumberMessage:
                'Veuillez entrer un numéro de téléphone valide',
            disableLengthCheck: false,
            keyboardType: TextInputType.phone,
            onChanged: (PhoneNumber phone) {
              // Update the complete phone number with country code
              setState(() {
                _completePhoneNumber = phone.completeNumber;
              });
            },
          ),

          const SizedBox(height: 24),

          // Login button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
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
                : const Text('RECEVOIR UN CODE'),
          ),

          const SizedBox(height: 16),

          // Divider with "or" text
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OU',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: 16),

          // Email login option
          OutlinedButton(
            onPressed: () {
              // Navigate to email login
              Navigator.pushNamed(context, '/email-login');
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('SE CONNECTER AVEC EMAIL'),
          ),

          const SizedBox(height: 24),

          // Register link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Vous n\'avez pas de compte?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('S\'inscrire'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
