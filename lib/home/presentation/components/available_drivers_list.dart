import 'package:flutter/material.dart';
import 'package:ndao/home/presentation/components/driver_item.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';
import 'package:provider/provider.dart';

/// A widget that displays a list of available drivers
class AvailableDriversList extends StatefulWidget {
  /// Creates a new AvailableDriversList
  const AvailableDriversList({super.key});

  @override
  State<AvailableDriversList> createState() => _AvailableDriversListState();
}

class _AvailableDriversListState extends State<AvailableDriversList> {
  late Future<List<UserEntity>> _driversFuture;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  void _loadDrivers() {
    final userRepository = Provider.of<UserRepository>(context, listen: false);
    _driversFuture = userRepository.getAvailableDrivers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Les chauffeurs à proximité",
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        FutureBuilder<List<UserEntity>>(
          future: _driversFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erreur lors du chargement des chauffeurs',
                        style: TextStyle(color: Colors.red),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _loadDrivers();
                          });
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final drivers = snapshot.data ?? [];

            if (drivers.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.no_transfer,
                        color: Colors.grey,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucun chauffeur disponible pour le moment',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _loadDrivers();
                          });
                        },
                        child: const Text('Actualiser'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final driver = drivers[index];
                  return DriverItem(driver: driver);
                },
                separatorBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(),
                  );
                },
                itemCount: drivers.length,
              ),
            );
          },
        ),
      ],
    );
  }
}
