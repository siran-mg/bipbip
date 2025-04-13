import 'package:flutter/material.dart';
import 'package:ndao/user/presentation/pages/phone_client_registration_page.dart';
import 'package:ndao/user/presentation/pages/phone_driver_registration_page.dart';

/// Page for selecting account type (client or driver)
class AccountTypeSelectionPage extends StatelessWidget {
  /// User ID from authentication
  final String userId;

  /// Phone number from authentication
  final String phoneNumber;

  /// Creates a new AccountTypeSelectionPage
  const AccountTypeSelectionPage({
    super.key,
    required this.userId,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un type de compte'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App logo or title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_bike,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bienvenue sur Ndao',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choisissez votre type de compte',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Client option
              _buildAccountTypeCard(
                context,
                title: 'Client',
                description: 'Je veux utiliser Ndao pour trouver des chauffeurs',
                icon: Icons.person,
                onTap: () {
                  // Navigate to client registration
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhoneClientRegistrationPage(
                        userId: userId,
                        phoneNumber: phoneNumber,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Driver option
              _buildAccountTypeCard(
                context,
                title: 'Chauffeur',
                description: 'Je veux utiliser Ndao pour offrir mes services',
                icon: Icons.drive_eta,
                onTap: () {
                  // Navigate to driver registration
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhoneDriverRegistrationPage(
                        userId: userId,
                        phoneNumber: phoneNumber,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a card for account type selection
  Widget _buildAccountTypeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
