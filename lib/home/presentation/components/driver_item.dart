import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';

class DriverItem extends StatelessWidget {
  /// The driver to display
  final UserEntity driver;

  const DriverItem({
    super.key,
    required this.driver,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Simulated distance - in a real app, this would be calculated
    final distance = 5.0; // km
    final estimatedTime = 15; // minutes

    // Determine color based on distance
    final Color distanceColor = distance <= 2.0
        ? Colors.green
        : distance <= 5.0
            ? Colors.orange
            : Colors.red;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Driver photo
                Hero(
                  tag: 'driver-${driver.id}',
                  child: CircleAvatar(
                    radius: 28.0,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: driver.profilePictureUrl != null
                        ? NetworkImage(driver.profilePictureUrl!)
                        : null,
                    child: driver.profilePictureUrl == null
                        ? Text(
                            driver.givenName[0] + driver.familyName[0],
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Driver info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            driver.driverDetails?.rating?.toString() ?? 'N/A',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.motorcycle,
                            size: 16,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              driver.driverDetails?.primaryVehicle != null
                                  ? '${driver.driverDetails!.primaryVehicle!.brand} ${driver.driverDetails!.primaryVehicle!.model}'
                                  : 'Véhicule inconnu',
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Distance indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: distanceColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$distance km',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: distanceColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$estimatedTime min',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.phone,
                  label: 'Appeler',
                  onPressed: () {
                    // Launch phone call
                    final phoneNumber = driver.phoneNumber;
                    // You would typically use url_launcher package to make a phone call
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Appel à $phoneNumber'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _ActionButton(
                  icon: Icons.message,
                  label: 'SMS',
                  onPressed: () {
                    // Launch SMS
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('SMS à ${driver.phoneNumber}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _ActionButton(
                  icon: Icons.directions,
                  label: 'Itinéraire',
                  onPressed: () {
                    // Show directions
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Affichage de l\'itinéraire'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
