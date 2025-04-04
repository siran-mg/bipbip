import 'package:flutter/material.dart';
import 'package:ndao/user/domain/interactors/register_user_interactor.dart';
import 'package:ndao/user/presentation/components/registration_form.dart';
import 'package:provider/provider.dart';

/// Registration page for new users
class RegistrationPage extends StatelessWidget {
  /// Creates a new RegistrationPage
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the register interactor from the provider
    final registerUserInteractor =
        Provider.of<RegisterUserInteractor>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: RegistrationForm(
              onRegister:
                  (givenName, familyName, email, phoneNumber, password) async {
                try {
                  // Use the register interactor to sign up
                  await registerUserInteractor.registerClient(
                    givenName,
                    familyName,
                    email,
                    phoneNumber,
                    password,
                  );

                  // Navigate to home page after successful registration
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                  return Future.value();
                } catch (e) {
                  // Log the error for debugging
                  print('Client registration error in page: $e');
                  // Rethrow the exception to be handled by the form
                  return Future.error(e);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
