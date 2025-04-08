import 'package:flutter/material.dart';
import 'package:ndao/location/presentation/components/driver_map_view.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:provider/provider.dart';

/// A page that displays the driver's location on a map
class DriverMapPage extends StatefulWidget {
  /// Creates a new DriverMapPage
  const DriverMapPage({super.key});

  @override
  State<DriverMapPage> createState() => _DriverMapPageState();
}

class _DriverMapPageState extends State<DriverMapPage> {
  UserEntity? _user;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final getCurrentUserInteractor =
          Provider.of<GetCurrentUserInteractor>(context, listen: false);
      final user = await getCurrentUserInteractor.execute();

      if (user == null) {
        setState(() {
          _errorMessage = 'Aucun utilisateur connecté';
          _isLoading = false;
        });
        return;
      }

      if (!user.isDriver) {
        setState(() {
          _errorMessage = 'Vous n\'êtes pas un chauffeur';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des données: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Position'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_user == null) {
      return const Center(
        child: Text('Aucun utilisateur connecté'),
      );
    }

    return DriverMapView(
      driver: _user!,
      trackInRealTime: true,
    );
  }
}
