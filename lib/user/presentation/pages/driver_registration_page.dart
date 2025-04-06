import 'package:flutter/material.dart';
import 'package:ndao/user/domain/interactors/login_interactor.dart';
import 'package:ndao/user/domain/interactors/register_user_interactor.dart';
import 'package:ndao/user/domain/interactors/upload_profile_photo_interactor.dart';
import 'package:ndao/user/presentation/components/stepper_driver_registration_form.dart';
import 'package:provider/provider.dart';

/// Registration page for new drivers
class DriverRegistrationPage extends StatelessWidget {
  /// Creates a new DriverRegistrationPage
  const DriverRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the interactors from the provider
    final registerUserInteractor =
        Provider.of<RegisterUserInteractor>(context, listen: false);
    final uploadProfilePhotoInteractor =
        Provider.of<UploadProfilePhotoInteractor>(context, listen: false);
    final loginInteractor =
        Provider.of<LoginInteractor>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devenir chauffeur'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StepperDriverRegistrationForm(
            onRegister: (
              givenName,
              familyName,
              email,
              phoneNumber,
              password,
              licensePlate,
              vehicleModel,
              vehicleBrand,
              vehicleType,
              profilePhoto,
              vehiclePhoto,
            ) async {
              try {
                // Use the register user interactor to sign up as a driver
                final userId = await registerUserInteractor.registerDriver(
                  givenName,
                  familyName,
                  email,
                  phoneNumber,
                  password,
                  licensePlate,
                  vehicleModel,
                  vehicleBrand,
                  vehicleType,
                  profilePhoto,
                  vehiclePhoto,
                );

                // Upload profile photo if provided
                if (profilePhoto != null) {
                  try {
                    await uploadProfilePhotoInteractor.execute(
                        userId, profilePhoto);
                  } catch (e) {
                    debugPrint('Failed to upload profile photo: $e');
                    // Continue anyway, as the user is already registered
                  }
                }

                // Upload vehicle photo if provided
                // Note: This would require a separate interactor for vehicle photos
                // For now, we'll just log that it would be uploaded
                if (vehiclePhoto != null) {
                  debugPrint('Vehicle photo would be uploaded here');
                }

                // Login the user after successful registration
                await loginInteractor.execute(email, password);

                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inscription réussie!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Navigate to home page
                  Navigator.pushReplacementNamed(context, '/home');
                }

                return Future.value();
              } catch (e) {
                // Log the error for debugging
                debugPrint('Driver registration error in page: $e');
                // Rethrow the exception to be handled by the form
                return Future.error(e);
              }
            },
          ),
        ),
      ),
    );
  }
}
