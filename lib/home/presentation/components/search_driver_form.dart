import 'package:flutter/material.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:provider/provider.dart';

class SearchDriverForm extends StatefulWidget {
  const SearchDriverForm({
    super.key,
  });

  @override
  State<SearchDriverForm> createState() => _SearchDriverFormState();
}

class _SearchDriverFormState extends State<SearchDriverForm> {
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();
  bool _isLoadingLocation = false;
  bool _isSearching = false;

  // Saved locations for quick selection
  final List<String> _savedLocations = [
    'Analakely',
    'Ivato',
    'Antananarivo Centre',
    'Ankorondrano',
  ];

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locatorProvider =
          Provider.of<LocatorProvider>(context, listen: false);

      // Show loading text immediately
      _sourceController.text = 'Recherche de votre position...';

      final position = await locatorProvider.getCurrentPosition();
      final address = await locatorProvider.getAddressFromPosition(position);

      if (mounted) {
        _sourceController.text = address ?? 'Position indéterminée';
      }
    } catch (e) {
      if (mounted) {
        _sourceController.text = 'Position indisponible';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _searchDrivers() {
    if (_sourceController.text.isEmpty || _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });

        // Show results (in a real app, this would navigate to results page)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Recherche de chauffeurs de ${_sourceController.text} à ${_destinationController.text}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Où allez-vous ?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Source field
            TextField(
              controller: _sourceController,
              readOnly: _isLoadingLocation,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Départ',
                labelText: 'Point de départ',
                prefixIcon: _isLoadingLocation
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(8.0),
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.location_on, color: colorScheme.primary),
                suffixIcon: IconButton(
                  icon: Icon(Icons.my_location, color: colorScheme.primary),
                  tooltip: 'Utiliser ma position actuelle',
                  onPressed: _getCurrentLocation,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Destination field
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Destination',
                labelText: 'Point d\'arrivée',
                prefixIcon:
                    Icon(Icons.location_searching, color: colorScheme.primary),
              ),
            ),
            const SizedBox(height: 8),

            // Saved locations
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _savedLocations.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      avatar: Icon(Icons.history,
                          size: 16, color: colorScheme.primary),
                      label: Text(_savedLocations[index]),
                      onPressed: () {
                        _destinationController.text = _savedLocations[index];
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Search button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSearching ? null : _searchDrivers,
                icon: _isSearching
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(_isSearching
                    ? 'Recherche en cours...'
                    : 'Rechercher un chauffeur'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
