import 'package:flutter/material.dart';

/// Footer for registration forms with login and alternative registration links
class RegistrationFooter extends StatelessWidget {
  /// Text for the alternative registration option
  final String alternativeText;
  
  /// Icon for the alternative registration option
  final IconData alternativeIcon;
  
  /// Label for the alternative registration option
  final String alternativeLabel;
  
  /// Route for the alternative registration option
  final String alternativeRoute;

  /// Creates a new RegistrationFooter
  const RegistrationFooter({
    super.key,
    required this.alternativeText,
    required this.alternativeIcon,
    required this.alternativeLabel,
    required this.alternativeRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Login link
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Vous avez déjà un compte?'),
              TextButton(
                onPressed: () {
                  // Navigate back to login page
                  Navigator.pop(context);
                },
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
        
        // Alternative registration link
        const SizedBox(height: 16),
        
        // Divider with text
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Ou inscrivez-vous comme',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Alternative registration button
        OutlinedButton.icon(
          onPressed: () {
            // Navigate to alternative registration page
            Navigator.pushReplacementNamed(context, alternativeRoute);
          },
          icon: Icon(alternativeIcon),
          label: Text(alternativeLabel),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }
}
