import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/driver_entity.dart';
import 'package:ndao/user/domain/interactors/register_driver_interactor.dart';
import 'package:ndao/user/presentation/components/driver_registration_form.dart';
import 'package:provider/provider.dart';

/// Registration page for new drivers
class DriverRegistrationPage extends StatelessWidget {
  /// Creates a new DriverRegistrationPage
  const DriverRegistrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the register driver interactor from the provider
    final registerDriverInteractor = Provider.of<RegisterDriverInteractor>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devenir chauffeur'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: DriverRegistrationForm(
              onRegister: (
                givenName,
                familyName,
                email,
                phoneNumber,
                password,
                licensePlate,
                vehicleModel,
                vehicleColor,
                vehicleType,
              ) async {
                try {
                  // Create vehicle info
                  final vehicleInfo = VehicleInfo(
                    licensePlate: licensePlate,
                    model: vehicleModel,
                    color: vehicleColor,
                    type: _mapVehicleType(vehicleType),
                  );
                  
                  // Use the register driver interactor to sign up
                  await registerDriverInteractor.execute(
                    givenName,
                    familyName,
                    email,
                    phoneNumber,
                    password,
                    vehicleInfo,
                  );
                  
                  // Navigate to home page after successful registration
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                  return Future.value();
                } catch (e) {
                  // Log the error for debugging
                  print('Driver registration error in page: $e');
                  // Rethrow the exception to be handled by the form
                  return Future.error(e);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
  
  /// Map string vehicle type to enum
  VehicleType _mapVehicleType(String vehicleType) {
    switch (vehicleType) {
      case 'car':
        return VehicleType.car;
      case 'bicycle':
        return VehicleType.bicycle;
      case 'motorcycle':
        return VehicleType.motorcycle;
      default:
        return VehicleType.other;
    }
  }
}
