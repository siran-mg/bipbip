import 'package:flutter/material.dart';
import 'package:ndao/user/domain/interactors/forgot_password_interactor.dart';
import 'package:provider/provider.dart';

/// Page for requesting a password reset
class ForgotPasswordPage extends StatefulWidget {
  /// Creates a new ForgotPasswordPage
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _resetEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get the forgot password interactor
        final forgotPasswordInteractor =
            Provider.of<ForgotPasswordInteractor>(context, listen: false);

        // Send password reset email
        await forgotPasswordInteractor.execute(_emailController.text.trim());

        // Show success message
        if (mounted) {
          setState(() {
            _isLoading = false;
            _resetEmailSent = true;
          });
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _resetEmailSent
              ? _buildSuccessMessage()
              : _buildResetForm(),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon and title
          const Icon(
            Icons.lock_reset,
            size: 64,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          Text(
            'Réinitialiser votre mot de passe',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

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
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            height: 50,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : FilledButton(
                    onPressed: _submitForm,
                    child: const Text(
                      'ENVOYER LE LIEN',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          // Back to login button
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Retour à la connexion'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          size: 80,
          color: Colors.green,
        ),
        const SizedBox(height: 24),
        Text(
          'Email envoyé!',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Nous avons envoyé un lien de réinitialisation à ${_emailController.text}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Veuillez vérifier votre boîte de réception et suivre les instructions pour réinitialiser votre mot de passe.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('RETOUR À LA CONNEXION'),
        ),
      ],
    );
  }
}
