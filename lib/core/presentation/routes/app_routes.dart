import 'package:flutter/material.dart';
import 'package:ndao/home/presentation/pages/home_wrapper.dart';
import 'package:ndao/location/presentation/pages/driver_map_page.dart';
import 'package:ndao/ride/presentation/pages/client_ride_requests_page.dart';
import 'package:ndao/ride/presentation/pages/nearby_ride_requests_page.dart';
import 'package:ndao/user/presentation/pages/driver_registration_page.dart';
import 'package:ndao/user/presentation/pages/email_login_page.dart';
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

  /// Email login route
  static const String emailLogin = '/email-login';

  /// Register route
  static const String register = '/register';

  /// Driver register route
  static const String driverRegister = '/driver-register';

  /// Forgot password route
  static const String forgotPassword = '/forgot-password';

  /// Driver map route
  static const String driverMap = '/driver-map';

  /// Nearby ride requests route
  static const String nearbyRideRequests = '/nearby-ride-requests';

  /// Client ride requests route
  static const String clientRideRequests = '/client-ride-requests';

  /// Get all routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initialRoute: (context) => const SplashPage(),
      login: (context) => const LoginPage(),
      emailLogin: (context) => const EmailLoginPage(),
      register: (context) => const RegistrationPage(),
      driverRegister: (context) => const DriverRegistrationPage(),
      forgotPassword: (context) => const ForgotPasswordPage(),
      home: (context) => const HomeWrapper(),
      driverMap: (context) => const DriverMapPage(),
      nearbyRideRequests: (context) => const NearbyRideRequestsPage(),
      clientRideRequests: (context) => const ClientRideRequestsPage(),
    };
  }
}
