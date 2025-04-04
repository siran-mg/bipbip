import 'package:flutter/material.dart';
import 'package:ndao/user/presentation/components/login_form.dart';

/// Login page for user authentication
class LoginPage extends StatelessWidget {
  /// Creates a new LoginPage
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: LoginForm(
              onLogin: (email, password) {
                // In a real app, this would call a login interactor/use case
                // For now, we'll just simulate a login with a delay
                return Future.delayed(
                  const Duration(seconds: 2),
                  () {
                    // Navigate to home page after successful login
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
