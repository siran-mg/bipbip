import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/routes/app_routes.dart';
import 'package:ndao/user/domain/interactors/register_user_interactor.dart';
import 'package:ndao/user/domain/interactors/upload_profile_photo_interactor.dart';
import 'package:ndao/user/presentation/components/stepper_registration_form.dart';
import 'package:provider/provider.dart';

/// Registration page for new users
class RegistrationPage extends StatelessWidget {
  /// Creates a new RegistrationPage
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the interactors from the provider
    final registerUserInteractor =
        Provider.of<RegisterUserInteractor>(context, listen: false);
    final uploadProfilePhotoInteractor =
        Provider.of<UploadProfilePhotoInteractor>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StepperRegistrationForm(
            onRegister: (givenName, familyName, email, phoneNumber, password,
                profilePhoto, profilePhotoBytes, profilePhotoExtension) async {
              try {
                // Use the register interactor to sign up
                final userId = await registerUserInteractor.registerClient(
                  givenName,
                  familyName,
                  email,
                  phoneNumber,
                  password,
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

                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inscription réussie!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Navigate to home page
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                }

                return Future.value();
              } catch (e) {
                // Log the error for debugging
                debugPrint('Client registration error in page: $e');
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
