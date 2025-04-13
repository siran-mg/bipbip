import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/routes/app_routes.dart';
import 'package:ndao/user/domain/interactors/login_interactor.dart';
import 'package:ndao/user/presentation/components/phone_login_form.dart';
import 'package:ndao/user/presentation/pages/otp_verification_page.dart';
import 'package:provider/provider.dart';

/// Login page for user authentication
class LoginPage extends StatelessWidget {
  /// Creates a new LoginPage
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the login interactor from the provider
    final loginInteractor =
        Provider.of<LoginInteractor>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: PhoneLoginForm(
              onLogin: (phoneNumber) async {
                try {
                  // Use the login interactor to initiate phone login
                  final userId =
                      await loginInteractor.executeWithPhone(phoneNumber);

                  // Navigate to OTP verification page
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtpVerificationPage(
                          phoneNumber: phoneNumber,
                          userId: userId,
                        ),
                      ),
                    );
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
