import 'package:flutter/material.dart';

/// A form for user login
class LoginForm extends StatefulWidget {
  /// Callback function when login is successful
  final Function(String email, String password) onLogin;

  /// Creates a new LoginForm
  const LoginForm({
    super.key,
    required this.onLogin,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Call the onLogin callback with the form values
      widget
          .onLogin(
        _emailController.text.trim(),
        _passwordController.text,
      )
          .then((_) {
        // Handle successful login if needed
      }).catchError((error) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${error.toString()}'),
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

          // Password field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              hintText: 'Entrez votre mot de passe',
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
                return 'Veuillez entrer votre mot de passe';
              }

              if (value.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }

              return null;
            },
          ),

          // Forgot password link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Navigate to forgot password page
              },
              child: const Text('Mot de passe oublié?'),
            ),
          ),

          const SizedBox(height: 24),

          // Login button
          SizedBox(
            height: 50,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : FilledButton(
                    onPressed: _submitForm,
                    child: const Text(
                      'SE CONNECTER',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
          ),

          const SizedBox(height: 24),

          // Register link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Vous n'avez pas de compte?"),
              TextButton(
                onPressed: () {
                  // Navigate to registration page
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Créer un compte'),
              ),
            ],
          ),

          // Driver register link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Vous êtes chauffeur?"),
              TextButton(
                onPressed: () {
                  // Navigate to driver registration page
                  Navigator.pushNamed(context, '/driver-register');
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
