import 'package:flutter/material.dart';
import 'package:ndao/user/domain/interactors/register_user_interactor.dart';
import 'package:ndao/user/presentation/components/driver_registration_form.dart';
import 'package:provider/provider.dart';

/// Registration page for new drivers
class DriverRegistrationPage extends StatelessWidget {
  /// Creates a new DriverRegistrationPage
  const DriverRegistrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the register user interactor from the provider
    final registerUserInteractor =
        Provider.of<RegisterUserInteractor>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devenir chauffeur'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: DriverRegistrationForm(
              onRegister: (
                givenName,
                familyName,
                email,
                phoneNumber,
                password,
                licensePlate,
                vehicleModel,
                vehicleColor,
                vehicleType,
              ) async {
                try {
                  // Use the register user interactor to sign up as a driver
                  await registerUserInteractor.registerDriver(
                    givenName,
                    familyName,
                    email,
                    phoneNumber,
                    password,
                    licensePlate,
                    vehicleModel,
                    vehicleColor,
                    vehicleType,
                  );

                  // Navigate to home page after successful registration
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                  return Future.value();
                } catch (e) {
                  // Log the error for debugging
                  print('Driver registration error in page: $e');
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
