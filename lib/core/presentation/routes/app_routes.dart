import 'package:flutter/material.dart';
import 'package:ndao/home/presentation/pages/home_wrapper.dart';
import 'package:ndao/user/presentation/pages/driver_registration_page.dart';
import 'package:ndao/user/presentation/pages/forgot_password_page.dart';
import 'package:ndao/user/presentation/pages/login_page.dart';
import 'package:ndao/user/presentation/pages/registration_page.dart';
import 'package:ndao/user/presentation/pages/splash_page.dart';

/// App routes configuration
class AppRoutes {
  /// Initial route
  static const String initialRoute = '/';

  /// Home route
  static const String home = '/home';

  /// Login route
  static const String login = '/login';

  /// Register route
  static const String register = '/register';

  /// Driver register route
  static const String driverRegister = '/driver-register';

  /// Forgot password route
  static const String forgotPassword = '/forgot-password';

  /// Get all routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initialRoute: (context) => const SplashPage(),
      login: (context) => const LoginPage(),
      register: (context) => const RegistrationPage(),
      driverRegister: (context) => const DriverRegistrationPage(),
      forgotPassword: (context) => const ForgotPasswordPage(),
      home: (context) => const HomeWrapper(),
    };
  }
}
