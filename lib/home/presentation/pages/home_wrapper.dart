import 'package:flutter/material.dart';
import 'package:ndao/core/presentation/routes/app_routes.dart';
import 'package:ndao/home/presentation/home_page.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:ndao/user/domain/interactors/logout_interactor.dart';
import 'package:ndao/user/presentation/pages/profile_page.dart';
import 'package:provider/provider.dart';

/// Wrapper for the home page that includes the bottom navigation bar
/// and handles logout functionality
class HomeWrapper extends StatefulWidget {
  /// Creates a new HomeWrapper
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _selectedIndex = 0;
  bool _isDriver = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfDriver();
  }

  Future<void> _checkIfDriver() async {
    try {
      final getCurrentUserInteractor =
          Provider.of<GetCurrentUserInteractor>(context, listen: false);
      final user = await getCurrentUserInteractor.execute();

      if (mounted) {
        setState(() {
          _isDriver = user?.isDriver ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDriver = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final logoutInteractor =
        Provider.of<LogoutInteractor>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
        title: const Text('Ndao'),
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                // Logout
                await logoutInteractor.execute();

                // Close loading dialog and navigate to login page
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login, (route) => false);
                }
              } catch (e) {
                // Close loading dialog
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close dialog

                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Déconnexion échouée: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _selectedIndex == 0 ? const HomePage() : const ProfilePage(),
      // Show map button only for drivers
      floatingActionButton: _isDriver && !_isLoading
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.driverMap);
              },
              tooltip: 'Voir ma position',
              child: const Icon(Icons.map),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
