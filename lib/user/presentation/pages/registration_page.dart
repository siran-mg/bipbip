import 'package:flutter/material.dart';
import 'package:ndao/user/presentation/components/registration_form.dart';

/// Registration page for new users
class RegistrationPage extends StatelessWidget {
  /// Creates a new RegistrationPage
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: RegistrationForm(
              onRegister: (name, email, phoneNumber, password) {
                // In a real app, this would call a registration interactor/use case
                // For now, we'll just simulate registration with a delay
                return Future.delayed(
                  const Duration(seconds: 2),
                  () {
                    // Navigate to home page after successful registration
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
