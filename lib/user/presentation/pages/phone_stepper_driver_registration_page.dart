import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/routes/app_routes.dart';
import 'package:ndao/user/domain/interactors/register_user_interactor.dart';
import 'package:ndao/user/domain/interactors/upload_profile_photo_interactor.dart';
import 'package:ndao/user/presentation/components/phone_stepper_driver_registration_form.dart';
import 'package:provider/provider.dart';

/// Registration page for new drivers with phone authentication
class PhoneStepperDriverRegistrationPage extends StatelessWidget {
  /// Phone number from authentication
  final String phoneNumber;

  /// User ID from authentication
  final String userId;

  /// Creates a new PhoneStepperDriverRegistrationPage
  const PhoneStepperDriverRegistrationPage({
    super.key,
    required this.phoneNumber,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    // Get the interactors from the provider
    final registerUserInteractor =
        Provider.of<RegisterUserInteractor>(context, listen: false);
    final uploadProfilePhotoInteractor =
        Provider.of<UploadProfilePhotoInteractor>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devenir chauffeur'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PhoneStepperDriverRegistrationForm(
            phoneNumber: phoneNumber,
            userId: userId,
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
              profilePhotoBytes,
              profilePhotoExtension,
              vehiclePhotoBytes,
              vehiclePhotoExtension,
            ) async {
              try {
                // Use the register user interactor to sign up as a driver with phone
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

                // Upload profile photo if provided
                if (kIsWeb &&
                    profilePhotoBytes != null &&
                    profilePhotoExtension != null) {
                  try {
                    await uploadProfilePhotoInteractor.executeWithBytes(
                        userId, profilePhotoBytes, profilePhotoExtension);
                  } catch (e) {
                    debugPrint('Failed to upload profile photo (web): $e');
                    // Continue anyway, as the user is already registered
                  }
                } else if (!kIsWeb && profilePhoto != null) {
                  try {
                    await uploadProfilePhotoInteractor.execute(
                        userId, profilePhoto);
                  } catch (e) {
                    debugPrint('Failed to upload profile photo (mobile): $e');
                    // Continue anyway, as the user is already registered
                  }
                }

                // Upload vehicle photo if provided
                // Note: This would require a separate interactor for vehicle photos
                // For now, we'll just log that it would be uploaded
                if (vehiclePhoto != null) {
                  debugPrint('Vehicle photo would be uploaded here');
                }

                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inscription réussie!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Navigate to home page and clear navigation stack
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.home, (route) => false);
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
