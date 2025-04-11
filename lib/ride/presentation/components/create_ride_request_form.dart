import 'package:flutter/material.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/ride/domain/providers/ride_request_provider.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:provider/provider.dart';

/// A form for creating a ride request
class CreateRideRequestForm extends StatefulWidget {
  /// Creates a new CreateRideRequestForm
  const CreateRideRequestForm({super.key});

  @override
  State<CreateRideRequestForm> createState() => _CreateRideRequestFormState();
}

class _CreateRideRequestFormState extends State<CreateRideRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _destinationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Où voulez-vous aller?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _destinationController,
            decoration: const InputDecoration(
              labelText: 'Destination',
              hintText: 'Ex: Analakely Market',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer une destination';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _budgetController,
            decoration: const InputDecoration(
              labelText: 'Budget (Ar)',
              hintText: 'Ex: 15000',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un budget';
              }
              if (double.tryParse(value) == null) {
                return 'Veuillez entrer un nombre valide';
              }
              if (double.parse(value) <= 0) {
                return 'Le budget doit être supérieur à 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Envoyer la demande'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get current user
        final getCurrentUserInteractor =
            Provider.of<GetCurrentUserInteractor>(context, listen: false);
        final currentUser = await getCurrentUserInteractor.execute();

        if (currentUser == null) {
          throw Exception('User not logged in');
        }

        // Get current location
        final locatorProvider =
            Provider.of<LocatorProvider>(context, listen: false);
        final currentPosition = await locatorProvider.getCurrentPosition();

        // Create ride request
        final rideRequestProvider =
            Provider.of<RideRequestProvider>(context, listen: false);
        await rideRequestProvider.createRideRequest(
          clientId: currentUser.id,
          pickupLatitude: currentPosition.latitude,
          pickupLongitude: currentPosition.longitude,
          destinationLatitude: currentPosition.latitude, // Placeholder
          destinationLongitude: currentPosition.longitude, // Placeholder
          destinationName: _destinationController.text,
          budget: double.parse(_budgetController.text),
        );

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Demande envoyée avec succès!'),
              backgroundColor: Colors.green,
            ),
          );

          // Clear form
          _destinationController.clear();
          _budgetController.clear();
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
