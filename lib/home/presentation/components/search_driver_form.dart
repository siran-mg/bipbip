import 'package:flutter/material.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:provider/provider.dart';

class SearchDriverForm extends StatelessWidget {
  const SearchDriverForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final source = TextEditingController();
    final destination = TextEditingController();
    // Get the locator provider from the provider
    final locatorProvider = Provider.of<LocatorProvider>(context);

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
                          await locatorProvider.getCurrentPosition();
                      final address = await locatorProvider
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
    // Get the locator provider from the provider
    final locatorProvider =
        Provider.of<LocatorProvider>(context, listen: false);

    try {
      final position = await locatorProvider.getCurrentPosition();
      // You can use the position here or show a snackbar with the coordinates
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Position: ${position.latitude}, ${position.longitude}'),
          ),
        );
      }
    } catch (e) {
      // Handle any errors that might occur
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
