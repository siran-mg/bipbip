import 'package:flutter/material.dart';
import 'package:ndao/location/infrastructure/providers/geo_locator_provider.dart';

class SearchDriverForm extends StatelessWidget {
  const SearchDriverForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final source = TextEditingController();
    final destination = TextEditingController();

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16.0,
            children: [
              Text(
                'Où allez-vous ?',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: source,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ma position actuelle',
                  prefixIcon: IconButton(
                    icon: Icon(Icons.my_location,
                        color: Theme.of(context).colorScheme.primary),
                    onPressed: () async {
                      source.clear();
                      final position =
                          await GeoLocatorProvider().getCurrentPosition();
                      final address = await GeoLocatorProvider()
                          .getAddressFromPosition(position);
                      source.text = address ?? 'Position indéterminée';
                    },
                  ),
                ),
              ),
              TextField(
                controller: destination,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Entrez votre destination',
                  prefixIcon: IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {},
                  child: Text('Trouver un taxi-moto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getCurrentLocation(BuildContext context) async {
    try {
      final locator = GeoLocatorProvider();
      final position = await locator.getCurrentPosition();
      // You can use the position here or show a snackbar with the coordinates
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Position: ${position.latitude}, ${position.longitude}'),
        ),
      );
    } catch (e) {
      // Handle any errors that might occur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
