import 'package:flutter/material.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';
import 'package:provider/provider.dart';

/// Splash page that checks authentication status and redirects accordingly
class SplashPage extends StatefulWidget {
  /// Creates a new SplashPage
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Check authentication status after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    final authRepository = Provider.of<AuthRepository>(context, listen: false);
    
    try {
      // Check if user is already authenticated
      final isAuthenticated = await authRepository.isAuthenticated();
      
      if (mounted) {
        if (isAuthenticated) {
          // User is authenticated, navigate to home page
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          // User is not authenticated, navigate to login page
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      // If there's an error, default to login page
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Icon(
              Icons.directions_bike,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            // App name
            Text(
              'Ndao',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
