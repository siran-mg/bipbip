import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverDetailsPage extends StatelessWidget {
  final UserEntity driver;

  const DriverDetailsPage({
    super.key,
    required this.driver,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du chauffeur'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver header with photo and basic info
            Container(
              color: colorScheme.primaryContainer,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Driver photo with enhanced Hero animation
                  Center(
                    child: Hero(
                      tag: 'driver-${driver.id}',
                      flightShuttleBuilder: (flightContext, animation,
                          flightDirection, fromHeroContext, toHeroContext) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + 0.5 * animation.value,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: driver.profilePictureUrl !=
                                        null
                                    ? NetworkImage(driver.profilePictureUrl!)
                                    : null,
                                child: driver.profilePictureUrl == null
                                    ? Text(
                                        driver.givenName[0] +
                                            driver.familyName[0],
                                        style: TextStyle(
                                          color: colorScheme.onPrimary,
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        );
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: driver.profilePictureUrl != null
                            ? NetworkImage(driver.profilePictureUrl!)
                            : null,
                        child: driver.profilePictureUrl == null
                            ? Text(
                                driver.givenName[0] + driver.familyName[0],
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Driver name
                  Text(
                    driver.fullName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Rating
                  if (driver.driverDetails?.rating != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${driver.driverDetails!.rating}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Contact buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ContactButton(
                    icon: Icons.phone,
                    label: 'Appeler',
                    onTap: () => _makePhoneCall(driver.phoneNumber),
                  ),
                  _ContactButton(
                    icon: Icons.message,
                    label: 'SMS',
                    onTap: () => _sendSms(driver.phoneNumber),
                  ),
                  if (driver.driverDetails?.currentLatitude != null &&
                      driver.driverDetails?.currentLongitude != null)
                    _ContactButton(
                      icon: Icons.directions,
                      label: 'Itinéraire',
                      onTap: () => _openMapsWithDirections(
                        driver.driverDetails!.currentLatitude!,
                        driver.driverDetails!.currentLongitude!,
                      ),
                    ),
                ],
              ),
            ),

            const Divider(),

            // Driver info section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Phone number
                  _InfoItem(
                    icon: Icons.phone,
                    label: 'Téléphone',
                    value: driver.phoneNumber,
                  ),

                  // Email if available
                  if (driver.email.isNotEmpty)
                    _InfoItem(
                      icon: Icons.email,
                      label: 'Email',
                      value: driver.email,
                    ),

                  // Status
                  _InfoItem(
                    icon: Icons.circle,
                    iconColor: driver.driverDetails?.isAvailable == true
                        ? Colors.green
                        : Colors.red,
                    label: 'Statut',
                    value: driver.driverDetails?.isAvailable == true
                        ? 'Disponible'
                        : 'Indisponible',
                  ),
                ],
              ),
            ),

            const Divider(),

            // Vehicle section
            if (driver.driverDetails?.primaryVehicle != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Véhicule',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildVehicleCard(
                        driver.driverDetails!.primaryVehicle!, theme),
                  ],
                ),
              ),

            // Other vehicles section
            if (driver.driverDetails?.vehicles != null &&
                driver.driverDetails!.vehicles.length > 1)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Autres véhicules',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...driver.driverDetails!.vehicles
                        .where((v) =>
                            v.id != driver.driverDetails!.primaryVehicle?.id)
                        .map((vehicle) => _buildVehicleCard(vehicle, theme)),
                  ],
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(VehicleEntity vehicle, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle name
            Text(
              '${vehicle.brand} ${vehicle.model}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Vehicle details
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.category,
                    label: 'Type',
                    value: _getVehicleTypeLabel(vehicle.type),
                  ),
                ),
                if (vehicle.licensePlate.isNotEmpty)
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.confirmation_number,
                      label: 'Immatriculation',
                      value: vehicle.licensePlate,
                    ),
                  ),
              ],
            ),

            // Vehicle photo if available
            if (vehicle.photoUrl != null && vehicle.photoUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    vehicle.photoUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getVehicleTypeLabel(String type) {
    switch (type) {
      case 'motorcycle':
        return 'Moto';
      case 'car':
        return 'Voiture';
      case 'suv':
        return 'SUV';
      case 'van':
        return 'Van';
      case 'truck':
        return 'Camion';
      default:
        return type;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $uri');
    }
  }

  Future<void> _sendSms(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $uri');
    }
  }

  Future<void> _openMapsWithDirections(double lat, double lng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $uri');
    }
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor ?? theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
