import 'package:flutter/material.dart';
import 'package:ndao/user/domain/providers/favorite_drivers_provider.dart';
import 'package:ndao/home/presentation/components/driver_item.dart';
import 'package:provider/provider.dart';

/// Page to display all favorite drivers
class FavoriteDriversPage extends StatefulWidget {
  /// Creates a new FavoriteDriversPage
  const FavoriteDriversPage({Key? key}) : super(key: key);

  @override
  State<FavoriteDriversPage> createState() => _FavoriteDriversPageState();
}

class _FavoriteDriversPageState extends State<FavoriteDriversPage> {
  @override
  void initState() {
    super.initState();
    // Schedule the loading for after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadFavoriteDrivers();
      }
    });
  }

  Future<void> _loadFavoriteDrivers() async {
    if (!mounted) return;

    try {
      final favoritesProvider =
          Provider.of<FavoriteDriversProvider>(context, listen: false);
      await favoritesProvider.loadFavoriteDrivers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading favorite drivers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chauffeurs favoris'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavoriteDrivers,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Consumer<FavoriteDriversProvider>(
        builder: (context, favoritesProvider, child) {
          if (favoritesProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (favoritesProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${favoritesProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      favoritesProvider.clearError();
                      _loadFavoriteDrivers();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final favoriteDrivers = favoritesProvider.favoriteDrivers;

          if (favoriteDrivers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.red,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Vous n\'avez pas encore de chauffeurs favoris',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Ajoutez des chauffeurs à vos favoris pour les retrouver facilement ici',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Trouver des chauffeurs'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => favoritesProvider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteDrivers.length,
              itemBuilder: (context, index) {
                final driver = favoriteDrivers[index];
                return DriverItem(driver: driver);
              },
            ),
          );
        },
      ),
    );
  }
}
