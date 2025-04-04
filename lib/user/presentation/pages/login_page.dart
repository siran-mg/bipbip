import 'package:flutter/material.dart';
import 'package:ndao/user/domain/interactors/login_interactor.dart';
import 'package:ndao/user/presentation/components/login_form.dart';
import 'package:provider/provider.dart';

/// Login page for user authentication
class LoginPage extends StatelessWidget {
  /// Creates a new LoginPage
  const LoginPage({Key? key}) : super(key: key);

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
            child: LoginForm(
              onLogin: (email, password) async {
                try {
                  // Use the login interactor to sign in
                  await loginInteractor.execute(email, password);

                  // Navigate to home page after successful login
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
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
