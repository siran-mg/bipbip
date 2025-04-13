import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/routes/app_routes.dart';
import 'package:ndao/user/domain/interactors/login_interactor.dart';
import 'package:ndao/user/presentation/components/otp_verification_form.dart';
import 'package:ndao/user/presentation/pages/account_type_selection_page.dart';
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
                  final result = await loginInteractor.verifyOTP(userId, otp);

                  if (context.mounted) {
                    if (result['userExists']) {
                      // User exists, navigate to home page
                      Navigator.pushNamedAndRemoveUntil(
                          context, AppRoutes.home, (route) => false);
                    } else {
                      // User doesn't exist, navigate to account type selection
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountTypeSelectionPage(
                            userId: result['userId'],
                            phoneNumber: result['phoneNumber'] != ''
                                ? result['phoneNumber']
                                : phoneNumber,
                          ),
                        ),
                      );
                    }
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
