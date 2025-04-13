import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/routes/app_routes.dart';
import 'package:ndao/user/domain/interactors/register_user_interactor.dart';
import 'package:ndao/user/presentation/components/phone_driver_registration_form.dart';
import 'package:provider/provider.dart';

/// Page for driver registration with phone number
class PhoneDriverRegistrationPage extends StatelessWidget {
  /// User ID from authentication
  final String userId;

  /// Phone number from authentication
  final String phoneNumber;

  /// Creates a new PhoneDriverRegistrationPage
  const PhoneDriverRegistrationPage({
    super.key,
    required this.userId,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    // Get the register user interactor from the provider
    final registerUserInteractor =
        Provider.of<RegisterUserInteractor>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription Chauffeur'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: PhoneDriverRegistrationForm(
              userId: userId,
              phoneNumber: phoneNumber,
              onRegister: (
                givenName,
                familyName,
                email,
                licensePlate,
                vehicleModel,
                vehicleBrand,
                vehicleType,
                profilePhoto,
                vehiclePhoto,
              ) async {
                try {
                  // Use the register user interactor to register the driver
                  await registerUserInteractor.registerDriverWithPhone(
                    givenName,
                    familyName,
                    phoneNumber,
                    email,
                    licensePlate,
                    vehicleModel,
                    vehicleBrand,
                    vehicleType,
                    profilePhoto,
                    vehiclePhoto,
                  );

                  // Navigate to home page after successful registration and clear navigation stack
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.home, (route) => false);
                  }
                  return Future.value();
                } catch (e) {
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
