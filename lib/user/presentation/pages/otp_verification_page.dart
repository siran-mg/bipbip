import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/routes/app_routes.dart';
import 'package:ndao/user/domain/interactors/login_interactor.dart';
import 'package:ndao/user/presentation/components/otp_verification_form.dart';
import 'package:provider/provider.dart';

/// OTP verification page for phone authentication
class OtpVerificationPage extends StatelessWidget {
  /// Phone number that received the OTP
  final String phoneNumber;
  
  /// User ID returned from the login initiation
  final String userId;

  /// Creates a new OtpVerificationPage
  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    // Get the login interactor from the provider
    final loginInteractor =
        Provider.of<LoginInteractor>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: OtpVerificationForm(
              phoneNumber: phoneNumber,
              onVerify: (otp) async {
                try {
                  // Use the login interactor to verify OTP
                  await loginInteractor.verifyOTP(userId, otp);

                  // Navigate to home page after successful verification and clear navigation stack
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
