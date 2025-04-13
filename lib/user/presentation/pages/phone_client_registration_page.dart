import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/routes/app_routes.dart';
import 'package:ndao/user/domain/interactors/register_user_interactor.dart';
import 'package:ndao/user/presentation/components/phone_client_registration_form.dart';
import 'package:provider/provider.dart';

/// Page for client registration with phone number
class PhoneClientRegistrationPage extends StatelessWidget {
  /// User ID from authentication
  final String userId;

  /// Phone number from authentication
  final String phoneNumber;

  /// Creates a new PhoneClientRegistrationPage
  const PhoneClientRegistrationPage({
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
        title: const Text('Inscription Client'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: PhoneClientRegistrationForm(
              userId: userId,
              phoneNumber: phoneNumber,
              onRegister: (givenName, familyName, email) async {
                try {
                  // Use the register user interactor to register the client
                  await registerUserInteractor.registerClientWithPhone(
                    givenName,
                    familyName,
                    phoneNumber,
                    email,
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
